class Item < ApplicationRecord
	has_many :survivor_items
	has_many :survivors, through: :survivor_items

	validates :name, presence: true, length: { in: 3..25 }, uniqueness: true
	validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
