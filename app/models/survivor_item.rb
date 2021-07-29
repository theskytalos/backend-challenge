class SurvivorItem < ApplicationRecord
  belongs_to :survivor
  belongs_to :item
	validates :item, uniqueness: { scope: :survivor, message: 'Repeated items are not allowed.' }
end
