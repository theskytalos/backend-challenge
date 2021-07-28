class Item < ApplicationRecord
	has_many :survivor_items
	has_many :survivors, through: :survivor_items
end
