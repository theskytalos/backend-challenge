# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

water = Item.create({
	name: 'Water',
	points: 4
})

food = Item.create({
	name: 'Food',
	points: 3
})

med = Item.create({
	name: 'Medication',
	points: 2
})

ammo = Item.create({
	name: 'Ammunition',
	points: 1
})

survivor1 = Survivor.create({
	name: Faker::Name.name,
	age: Faker::Number.between(from: 15, to: 80),
	gender: Faker::Gender.type,
	last_pos_latitude: Faker::Address.latitude,
	last_pos_longitude: Faker::Address.longitude
})

inventory_w = SurvivorItem.create({
	survivor: survivor1,
	item: water,
	item_count: 3
})

inventory_f = SurvivorItem.create({
	survivor: survivor1,
	item: food,
	item_count: 1
})

inventory_a = SurvivorItem.create({
	survivor: survivor1,
	item: ammo,
	item_count: 50
})