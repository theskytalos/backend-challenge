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

describe 'Survivors API', type: :request do
	it 'returns all survivors' do

		FactoryBot.create(:survivor, {
			name: Faker::Name.name,
			age: Faker::Number.between(from: 15, to: 80),
			gender: Faker::Gender.type,
			last_pos_latitude: Faker::Address.latitude,
			last_pos_longitude: Faker::Address.longitude
		})

		FactoryBot.create(:survivor, {
			name: Faker::Name.name,
			age: Faker::Number.between(from: 15, to: 80),
			gender: Faker::Gender.type,
			last_pos_latitude: Faker::Address.latitude,
			last_pos_longitude: Faker::Address.longitude
		})

		get '/api/v1/survivors'

		expect(response).to have_http_status(:success)
		expect(JSON.parse(response.body)['data'].size).to eq(2)
	end

	it 'doesn\'t find any survivor' do
		get '/api/v1/survivors/1'

		expect(response).to have_http_status(:not_found)
	end

	it 'returns one survivor' do
		FactoryBot.create(:survivor, {
			name: Faker::Name.name,
			age: Faker::Number.between(from: 15, to: 80),
			gender: Faker::Gender.type,
			last_pos_latitude: Faker::Address.latitude,
			last_pos_longitude: Faker::Address.longitude
		})

		get '/api/v1/survivors/1'

		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).not_to be_empty
	end

	context 'with valid parameters' do
		let(:valid_params) do
			{
				"name": "José Venâncio",
				"age": "22",
				"gender": "male",
				"last_pos_latitude": "43.554543",
				"last_pos_longitude": "64.43432",
				"inventory": [
					{
						"id": "1",
						"item_count": "2"
					},
					{
						"id": "3",
						"item_count": "13"
					}
				]
			}
		end

		it 'create one survivor' do
			generate_items

			post '/api/v1/survivors', params: valid_params

			expect(response).to have_http_status(:created)
			expect(JSON.parse(response.body)['data']).not_to be_empty
		end
	end

	context 'with invalid parameters' do
		let(:invalid_params_empty_position) do
			{
				"name": "José Venâncio",
				"age": "22",
				"gender": "male",
				"last_pos_latitude": "",
				"last_pos_longitude": "",
				"inventory": [
					{
						"id": "1",
						"item_count": "2"
					},
					{
						"id": "3",
						"item_count": "13"
					}
				]
			}
		end

		let(:invalid_params_invalid_age) do
			{
				"name": "José Venâncio",
				"age": "abc",
				"gender": "male",
				"last_pos_latitude": "43.554543",
				"last_pos_longitude": "64.43432",
				"inventory": [
					{
						"id": "1",
						"item_count": "2"
					},
					{
						"id": "3",
						"item_count": "13"
					}
				]
			}
		end

		let(:invalid_params_invalid_item) do
			{
				"name": "José Venâncio",
				"age": "22",
				"gender": "male",
				"last_pos_latitude": "43.554543",
				"last_pos_longitude": "64.43432",
				"inventory": [
					{
						"id": "1",
						"item_count": "2"
					},
					{
						"id": "8",
						"item_count": "13"
					}
				]
			}
		end

		it 'tries to create one survivor without coordinates' do
			post '/api/v1/survivors', params: invalid_params_empty_position

			expect(response).to have_http_status(:unprocessable_entity)			
		end

		it 'tries to create one survivor with invalid age' do
			post '/api/v1/survivors', params: invalid_params_invalid_age

			expect(response).to have_http_status(:unprocessable_entity)			
		end

		it 'tries to create one survivor with inexistent items' do
			post '/api/v1/survivors', params: invalid_params_invalid_item

			expect(response).to have_http_status(:not_found)			
		end
	end
end