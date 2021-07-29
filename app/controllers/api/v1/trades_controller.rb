module Api
	module V1
		class TradesController < ApplicationController
			def trade
				# Checks if both traders are the same survivor
				if params[:id_1] == params[:id_2]
					render json: { status: 'FAILURE', message: 'A survivor can\'t trade with himself.', data: {} }, status: :unprocessable_entity
					return
				end

				# Checks if the first trader does exists
				unless Survivor.exists?(params[:id_1])
					render json: { status: 'FAILURE', message: 'The first survivor doesn\'t exist.', data: {} }, status: :unprocessable_entity
					return
				end

				# Checks if the second trader does exists
				unless Survivor.exists?(params[:id_2])
					render json: { status: 'FAILURE', message: 'The second survivor doesn\'t exist.', data: {} }, status: :unprocessable_entity
					return
				end

				trader1 = Survivor.find(params[:id_1])
				trader2 = Survivor.find(params[:id_2])
				
				# Check if any of the survivors are infected
				unless trader1[:infected_count] < 3
					render json: { status: 'FAILURE', message: 'The first survivor is infected. Therefore he/she can\'t trade.', data: {} }, status: :unprocessable_entity
					return
				end

				unless trader2[:infected_count] < 3
					render json: { status: 'FAILURE', message: 'The second survivor is infected. Therefore he/she can\'t trade.', data: {} }, status: :unprocessable_entity
					return
				end

				items_1 = params[:f_items]
				items_2 = params[:s_items]

				first_set_value = 0
				included_items_1 = []
				for item in items_1 do
					# Checks if the item exists
					unless Item.exists?(item[:id])
						render json: { status: 'FAILURE', message: 'The item ' + item[:id] + ' in the first set doesn\'t exist.' , data: {} }, status: :unprocessable_entity
						return
					end

					# Checks if the first trader has the item
					found_item = false
					enough = false
					for survivor_item in trader1.survivor_items.includes(:item) do
						if survivor_item[:item_id].to_i == item[:id].to_i
							found_item = true

							# If he does have the item, checks if he does have the enough amount to trade
							if survivor_item[:item_count].to_i >= item[:amount].to_i
								enough = true
							end

							break
						end
					end

					unless found_item == true
						render json: { status: 'FAILURE', message: 'The first survivor doesn\'t have the item ' + Item.find(item[:id])[:name] + '.' , data: {} }, status: :unprocessable_entity
						return
					end

					unless enough == true
						render json: { status: 'FAILURE', message: 'The first survivor doesn\'t have enough of the item ' + Item.find(item[:id])[:name] + '.' , data: {} }, status: :unprocessable_entity
						return
					end

					# Checks if there is a repeated item id
					if included_items_1.include? item[:id]
						render json: { status: 'FAILURE', message: 'The item ' + Item.find(item[:id])[:name] + ' can\'t be included more than once.' , data: {} }, status: :unprocessable_entity
						return
					end

					included_items_1.push(item[:id])

					first_set_value += Item.find(item[:id])[:points].to_i * item[:amount].to_i
				end

				second_set_value = 0
				included_items_2 = []
				for item in items_2 do
					# Checks if the item exists
					unless Item.exists?(item[:id])
						render json: { status: 'FAILURE', message: 'The item ' + item[:id] + ' in the second set doesn\'t exist.' , data: {} }, status: :unprocessable_entity
						return
					end

					# Checks if the second trader has the item
					found_item = false
					enough = false
					for survivor_item in trader2.survivor_items.includes(:item) do
						if survivor_item[:item_id].to_i == item[:id].to_i
							found_item = true

							# If he does have the item, checks if he does have the enough amount to trade
							if survivor_item[:item_count].to_i >= item[:amount].to_i
								enough = true
							end

							break
						end
					end

					unless found_item == true
						render json: { status: 'FAILURE', message: 'The second survivor doesn\'t have the item ' + Item.find(item[:id])[:name] + '.' , data: {} }, status: :unprocessable_entity
						return
					end
					
					unless enough == true
						render json: { status: 'FAILURE', message: 'The second survivor doesn\'t have enough of the item ' + Item.find(item[:id])[:name] + '.' , data: {} }, status: :unprocessable_entity
						return
					end

					# Checks if there is a repeated item id
					if included_items_2.include? item[:id]
						render json: { status: 'FAILURE', message: 'The item ' + Item.find(item[:id])[:name] + ' can\'t be included more than once.' , data: {} }, status: :unprocessable_entity
						return
					end

					included_items_2.push(item[:id])

					second_set_value += Item.find(item[:id])[:points].to_i * item[:amount].to_i
				end

				# Check if they are equivalent in value
				unless first_set_value == second_set_value
					render json: { status: 'FAILURE', message: 'One set isn\'t equal the other in terms of points. (' + first_set_value.to_s + '/' + second_set_value.to_s + ')', data: {} }, status: :unprocessable_entity
					return
				end

				# Trade logic itself
				# Remove the items_1 set from trader1 and give it to trader2
				for item in items_1 do
					item_to_remove = trader1.survivor_items.where(['item_id = ?', item[:id]]).first

					unless item_to_remove.update(item_count: item_to_remove[:item_count].to_i - item[:amount].to_i)
						render json: { status: 'FAILURE', message: 'The trade couldn\'t be done.', data: {} }, status: :internal_server_error
						return
					end

					# If the trader1 give all of it's item, remove it completely from the database
					unless item_to_remove[:item_count].to_i > 0
						item_to_remove.destroy
					end

					item_to_add = trader2.survivor_items.where(['item_id = ?', item[:id]]).first

					# If the second trader does have the item, it is incremented. A new survivor_items record is created if not.
					if !item_to_add.nil?
						unless item_to_add.update(item_count: item_to_add[:item_count].to_i + item[:amount].to_i)
							render json: { status: 'FAILURE', message: 'The trade couldn\'t be done.', data: {} }, status: :internal_server_error
							return
						end
					else
						si = SurvivorItem.create({
							survivor_id: trader2[:id],
							item_id: item[:id],
							item_count: item[:amount]
						})

						unless si.save
							render json: { status: 'FAILURE', message: 'The trade couldn\'t be done.', data: {} }, status: :internal_server_error
							return
						end
					end
				end

				# Remove the items_2 set from trader2 and give it to trader1
				for item in items_2 do
					item_to_remove = trader2.survivor_items.where(['item_id = ?', item[:id]]).first

					unless item_to_remove.update(item_count: item_to_remove[:item_count].to_i - item[:amount].to_i)
						render json: { status: 'FAILURE', message: 'The trade couldn\'t be done.', data: {} }, status: :internal_server_error
						return
					end

					# If the trader2 give all of it's item, remove it completely from the database
					unless item_to_remove[:item_count].to_i > 0
						item_to_remove.destroy
					end

					item_to_add = trader1.survivor_items.where(['item_id = ?', item[:id]]).first

					# If the second trader does have the item, it is incremented. A new survivor_items record is created if not.
					if !item_to_add.nil?
						unless item_to_add.update(item_count: item_to_add[:item_count].to_i + item[:amount].to_i)
							render json: { status: 'FAILURE', message: 'The trade couldn\'t be done.', data: {} }, status: :internal_server_error
							return
						end
					else
						si = SurvivorItem.create({
							survivor_id: trader1[:id],
							item_id: item[:id],
							item_count: item[:amount]
						})

						unless si.save
							render json: { status: 'FAILURE', message: 'The trade couldn\'t be done.', data: {} }, status: :internal_server_error
							return
						end
					end
				end

				render json: { status: 'SUCCESS', message: 'The trade was successfully made.', data: {} }
			end
		end
	end
end