class Survivor < ApplicationRecord
	has_many :survivor_items
	has_many :items, through: :survivor_items

	validates :name, presence: true, length: { in: 3..30 }, uniqueness: true
	validates :age, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 15, less_than_or_equal_to: 80 }
	validates :gender, presence: true
	validates :last_pos_latitude, presence: true, numericality: true
	validates :last_pos_longitude, presence: true, numericality: true
	validates :infected_count, presence: false, numericality: { only_integer: true }
	
	attribute :infected_count, :integer, default: 0

	def as_json(options={})
		super(include: :items)
	end
end
