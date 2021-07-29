module Api
	module V1
		class SurvivorsController < ApplicationController
			def index
				survivors = Survivor.order('updated_at DESC')
				render json: { status: 'SUCCESS', message: 'Loaded survivors', data: survivors }
			end

			def show
				begin
					survivor = Survivor.find(params[:id])

					render json: { status: 'SUCCESS', message: 'Loaded survivor', data: survivor }
				rescue ActiveRecord::RecordNotFound
					render json: { status: 'FAILURE', message: 'Survivor Not Found', data: {} }, status: :not_found
				end
			end

			def create
				survivor = Survivor.create(survivor_params)

				params.require(:inventory)

				if survivor.save
					params.permit(:survivor, :inventory)
					for item in params[:inventory] do

						unless Item.exists? (item[:id])
							render json: { status: 'FAILURE', message: 'There is no item with id ' + item[:id].to_s, data: {} }, status: :not_found
							return
						end

						SurvivorItem.create({
							survivor_id: survivor[:id],
							item_id: item[:id],
							item_count: item[:item_count]
						})
					end

					render json: { status: 'SUCCESS', message: 'Created survivor', data: survivor }, status: :created
				else
					render json: { status: 'FAILURE', message: survivor.errors, data: {} }, status: :unprocessable_entity
				end
			end

			def update_location
				survivor = Survivor.find(params[:id])

				if survivor.update(location_params)
					render json: { status: 'SUCCESS', message: 'Survivor\'s location updated.', data: survivor }
				else
					render json: { status: 'FAILURE', message: 'Survivor\'s location couldn\'t be updated.', data: survivor.errors }, stauts: :unprocessable_entity
				end
			end

			def flag_survivor
				survivor = Survivor.find(params[:id])

				if survivor.update(infected_count: survivor[:infected_count] + 1)
					render json: { status: 'SUCCESS', message: 'The survivor ' + survivor.name + ' has been flagged as infected.', data: survivor }
				else
					render json: { status: 'FAILURE', message: 'The survivor couldn\'t be flagged as infected.', data: survivor.errors }, status: :unprocessable_entity
				end
			end

			private

			def survivor_params
				params.permit(:name, :age, :gender, :last_pos_latitude, :last_pos_longitude)
			end

			def item_params(item_p)
				item_p.permit(:id, :item_count)
			end

			def location_params
				params.require(:last_pos_latitude)
				params.require(:last_pos_longitude)
				params.permit(:last_pos_latitude, :last_pos_longitude)
			end
		end
	end
end