module Api
	module V1
		class ReportsController < ApplicationController
			def infected
				survivors_count = Survivor.all.count
				infected_survivors_count = Survivor.where('infected_count >= 3').count

				infected_proportion = 0.0

				if survivors_count != 0.0
					infected_proportion = infected_survivors_count.to_f / survivors_count.to_f * 100.0
				end

				infected_proportion = infected_proportion.to_s + "%"

				render json: { status: 'SUCCESS', message: 'Infected survivors percentage retrieved.', data: infected_proportion }
			end

			def non_infected
				survivors_count = Survivor.all.count
				non_infected_survivors_count = Survivor.where('infected_count < 3').count

				non_infected_proportion = 0.0

				if survivors_count != 0.0
					non_infected_proportion = non_infected_survivors_count.to_f / survivors_count.to_f * 100.0	
				end

				non_infected_proportion = non_infected_proportion.to_s + "%"

				render json: { status: 'SUCCESS', message: 'Non-infected survivors percentage retrieved.', data: non_infected_proportion }
			end

			def average_amount_by_survivor
				survivors = Survivor.all

				begin
					item = Item.find(params[:id])
				rescue ActiveRecord::RecordNotFound
					render json: { status: 'FAILURE', message: 'Item not found', data: {} }, status: :not_found
					return
				end

				average = 0
				items_added = 0
				for survivor in survivors do
					item_count = survivor.survivor_items.includes(:item).where(['item_id = ?', params[:id]]).pluck(:item_count).at(0)

					if item_count != nil
						items_added += item_count
					end
				end

				if survivors.count != 0
					average = items_added / survivors.count.to_f
				end

				render json: { status: 'SUCCESS', message: 'Average amount of ' + item[:name] + ' per survivor retrieved.', data: average.to_s }
			end

			def points_lost
			end
		end
	end
end
