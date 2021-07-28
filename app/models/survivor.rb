class Survivor < ApplicationRecord
	has_many :survivor_items
	has_many :items, through: :survivor_items
	attribute :infected_count, :integer, default: 0

	def as_json(options={})
		super(include: :items)
	end
end
