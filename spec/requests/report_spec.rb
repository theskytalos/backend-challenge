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

describe 'Reports API', type: :request do
	it 'gets percentage of infected survivors (no records)' do
		get '/api/v1/reports/infected'

		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).to eq('0.0%')
	end

	it 'gets percentage of infected survivors (one record)' do
		FactoryBot.create(:survivor, {
			name: Faker::Name.name,
			age: Faker::Number.between(from: 15, to: 80),
			gender: Faker::Gender.type,
			last_pos_latitude: Faker::Address.latitude,
			last_pos_longitude: Faker::Address.longitude
		})

		3.times do
			put '/api/v1/survivors/flag/1'
		end

		get '/api/v1/reports/infected'
		
		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).to eq('100.0%')
	end

	it 'gets percentage of infected survivors (multiple records)' do
		3.times do
			FactoryBot.create(:survivor, {
				name: Faker::Name.name,
				age: Faker::Number.between(from: 15, to: 80),
				gender: Faker::Gender.type,
				last_pos_latitude: Faker::Address.latitude,
				last_pos_longitude: Faker::Address.longitude
			})
		end

		3.times do
			put '/api/v1/survivors/flag/1'
			put '/api/v1/survivors/flag/3'
		end

		2.times do
			put '/api/v1/survivors/flag/3'
		end

		get '/api/v1/reports/infected'
		
		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).to eq('66.66666666666666%')
	end

	it 'gets percentage of non-infected survivors (no records)' do
		get '/api/v1/reports/non-infected'

		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).to eq('0.0%')
	end

	it 'gets percentage of non-infected survivors (one record)' do
		FactoryBot.create(:survivor, {
			name: Faker::Name.name,
			age: Faker::Number.between(from: 15, to: 80),
			gender: Faker::Gender.type,
			last_pos_latitude: Faker::Address.latitude,
			last_pos_longitude: Faker::Address.longitude
		})

		2.times do
			put '/api/v1/survivors/flag/1'
		end

		get '/api/v1/reports/infected'
		
		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).to eq('0.0%')
	end

	it 'gets percentage of non-infected survivors (multiple records)' do
		3.times do
			FactoryBot.create(:survivor, {
				name: Faker::Name.name,
				age: Faker::Number.between(from: 15, to: 80),
				gender: Faker::Gender.type,
				last_pos_latitude: Faker::Address.latitude,
				last_pos_longitude: Faker::Address.longitude
			})
		end

		3.times do
			put '/api/v1/survivors/flag/1'
			put '/api/v1/survivors/flag/3'
		end

		2.times do
			put '/api/v1/survivors/flag/3'
		end

		get '/api/v1/reports/non-infected'
		
		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).to eq('33.33333333333333%')
	end

	it 'gets average amount of an item per survivor (non-existent item)' do
		get '/api/v1/reports/average/6'

		expect(response).to have_http_status(:not_found)
	end

	it 'gets average amount of an item per survivor (one survivor)' do
		generate_items

		sv = FactoryBot.create(:survivor, {
			name: Faker::Name.name,
			age: Faker::Number.between(from: 15, to: 80),
			gender: Faker::Gender.type,
			last_pos_latitude: Faker::Address.latitude,
			last_pos_longitude: Faker::Address.longitude
		})

		FactoryBot.create(:survivor_item, {
			survivor_id: sv[:id],
			item_id: 3,
			item_count: 13
		})

		get '/api/v1/reports/average/3'

		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).to eq('13.0')
	end

	it 'gets average amount of an item per survivor (multiple survivor)' do
		generate_items

		5.times do
			FactoryBot.create(:survivor, {
				name: Faker::Name.name,
				age: Faker::Number.between(from: 15, to: 80),
				gender: Faker::Gender.type,
				last_pos_latitude: Faker::Address.latitude,
				last_pos_longitude: Faker::Address.longitude
			})
		end
		
		FactoryBot.create(:survivor_item, {
			survivor_id: 3,
			item_id: 3,
			item_count: 15
		})

		get '/api/v1/reports/average/3'

		expect(response).to have_http_status(:ok)
		expect(JSON.parse(response.body)['data']).to eq('3.0')
	end
end