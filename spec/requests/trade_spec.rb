require 'rails_helper'

def generate_items
	water = FactoryBot.create(:item, {
		name: 'Water',
		points: 4
	})
	
	food = FactoryBot.create(:item, {
		name: 'Food',
		points: 3
	})
	
	med = FactoryBot.create(:item, {
		name: 'Medication',
		points: 2
	})
	
	ammo = FactoryBot.create(:item, {
		name: 'Ammunition',
		points: 1
	})
end

def generate_survivors
	generate_items
	
	# Trader 1
	sv1 = FactoryBot.create(:survivor, {
		name: Faker::Name.name,
		age: Faker::Number.between(from: 15, to: 80),
		gender: Faker::Gender.type,
		last_pos_latitude: Faker::Address.latitude,
		last_pos_longitude: Faker::Address.longitude
	})

	FactoryBot.create(:survivor_item, {
		survivor_id: sv1[:id],
		item_id: 1,
		item_count: 1
	})

	FactoryBot.create(:survivor_item, {
		survivor_id: sv1[:id],
		item_id: 3,
		item_count: 1
	})

	# Trader 2
	sv2 = FactoryBot.create(:survivor, {
		name: Faker::Name.name,
		age: Faker::Number.between(from: 15, to: 80),
		gender: Faker::Gender.type,
		last_pos_latitude: Faker::Address.latitude,
		last_pos_longitude: Faker::Address.longitude
	})

	FactoryBot.create(:survivor_item, {
		survivor_id: sv2[:id],
		item_id: 4,
		item_count: 6
	})

	FactoryBot.create(:survivor_item, {
		survivor_id: sv2[:id],
		item_id: 2,
		item_count: 2
	})
end

describe 'Trades API', type: :request do
	let(:valid_params) do
		{
			"f_items": [
				{
					"id": "1",
					"amount": "1"
				},
				{
					"id": "3",
					"amount": "1"
				}
			],
			"s_items": [
				{
					"id": "4",
					"amount": "6"
				}
			]
		}
	end

	let(:invalid_params_invalid_item) do
		{
			"f_items": [
				{
					"id": "1",
					"amount": "1"
				}
			],
			"s_items": [
				{
					"id": "7",
					"amount": "2"
				}
			]
		}
	end

	let(:invalid_params_dont_have_item) do
		{
			"f_items": [
				{
					"id": "2",
					"amount": "1"
				}
			],
			"s_items": [
				{
					"id": "7",
					"amount": "2"
				}
			]
		}
	end

	let(:invalid_params_repeated_items) do
		{
			"f_items": [
				{
					"id": "1",
					"amount": "1"
				},
				{
					"id": "1",
					"amount": "1"
				}
			],
			"s_items": [
				{
					"id": "7",
					"amount": "2"
				}
			]
		}
	end

	let(:invalid_params_different_values) do
		{
			"f_items": [
				{
					"id": "1",
					"amount": "1"
				},
				{
					"id": "3",
					"amount": "1"
				}
			],
			"s_items": [
				{
					"id": "4",
					"amount": "6"
				},
				{
					"id": "2",
					"amount": "1"
				}
			]
		}
	end

	it 'tries to perform a trade between the same survivor' do
		generate_survivors

		put '/api/v1/trade/1/1', params: valid_params

		expect(response).to have_http_status(:unprocessable_entity)
	end

	it 'tries to perform a trade with inexistent item' do
		generate_survivors

		put '/api/v1/trade/1/2', params: invalid_params_invalid_item

		expect(response).to have_http_status(:unprocessable_entity)
	end

	it 'tries to perform a trade with inexistent survivor' do
		generate_survivors

		put '/api/v1/trade/1/9', params: valid_params

		expect(response).to have_http_status(:unprocessable_entity)
	end

	it 'tries to perform a trade with infected survivor' do
		generate_survivors

		3.times do
			put '/api/v1/survivors/flag/1'
		end

		put '/api/v1/trade/1/2', params: valid_params

		expect(response).to have_http_status(:unprocessable_entity)
	end

	it 'tries to perform a trade which one survivor doesn\'t have the item he says he has' do
		generate_survivors

		put '/api/v1/trade/1/2', params: invalid_params_dont_have_item

		expect(response).to have_http_status(:unprocessable_entity)
	end

	it 'tries to perform a trade with repeated items ids' do
		generate_survivors

		put '/api/v1/trade/1/2', params: invalid_params_repeated_items

		expect(response).to have_http_status(:unprocessable_entity)
	end

	it 'tries to perform a trade with different values in sets' do
		generate_survivors

		put '/api/v1/trade/1/2', params: invalid_params_different_values

		expect(response).to have_http_status(:unprocessable_entity)
	end

	it 'tries to perform a valid trade' do
		generate_survivors

		put '/api/v1/trade/1/2', params: valid_params

		expect(JSON.parse(response.body)['message']).to eq('The trade was successfully made.')
		expect(response).to have_http_status(:ok)
	end
end