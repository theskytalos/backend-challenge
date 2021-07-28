module Api
	module V1
		class TradesController < ApplicationController
			def trade
				if params[:id_1] == params[:id_2]
					render json: { status: 'FAILURE', message: 'A survivor can\'t trade with himself.', data: {} }, status: :unprocessable_entity
					return
				end

				unless Survivor.exists?(params[:id_1])
					render json: { status: 'FAILURE', message: 'The first survivor doesn\'t exist.', data: {} }, status: :unprocessable_entity
					return
				end

				unless Survivor.exists?(params[:id_2])
					render json: { status: 'FAILURE', message: 'The second survivor doesn\'t exist.', data: {} }, status: :unprocessable_entity
					return
				end

				# check if everything exists

				# check if both survivors do have what they trying to trade

				# check if they are equivalent in value

			end
		end
	end
end