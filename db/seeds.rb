# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Users

CITIES = [
  "Wellington", "Auckland", "Christchurch", "Hamilton", "Dunedin", "Lincoln", "Oamaru",
  "Whangarei", "Wanaka", "Hawea", "Timaru", "Rotorua", "Ashburton", "Kaikoura", "Fairlie"
]

print "Creating users "

30.times do
  print "."
  name = Faker::Name.name

  User.create!(
    name: name,
    address: "#{Faker::Address.street_address}\n#{CITIES.sample}",
    email: Faker::Internet.free_email(name),
    password: "0hsosecret",
    password_confirmation: "0hsosecret"
  )
end

puts

# Products

print "Creating products "

# category => product types (categories are not yet used)
PRODUCT_TYPES = {
  "Artworks" => ["painting", "sculpture", "print", "poster"],
  "Clothing" => ["T-shirt", "jersey", "hoodie", "shirt", "trousers", "socks", "skirt", "dress"],
  "Accessories" => ["scarf", "hat", "gloves"],
  "Jewelry" => ["ring", "necklace", "earrings"],
  "Miscellaneous" => ["loot box", "mystery gift"]
}

# creates categories in system
PRODUCT_TYPES.each_pair do |category, sub|
  Category.create(name: category)
  print category.class
  print "#{category}"
end

ALL_PRODUCT_TYPES = PRODUCT_TYPES.values.flatten

PRODUCT_NAMES = [
  50.times.map { Faker::App.name },
  50.times.map { Faker::Team.creature.singularize },
  50.times.map { Faker::Book.title },
  10.times.map { Faker::Book.genre },
  50.times.map { Faker::Hipster.word },
  50.times.map { Faker::StarWars.character }
].flatten

100.times do
  print "."

  Product.create!(
    name: "#{PRODUCT_NAMES.sample.titleize} #{ALL_PRODUCT_TYPES.sample}",
    description: Faker::Hipster.paragraph,
    price: rand(1..500) + [0, 0.50, 0.99].sample,
    quantity: 1, # Will be updated later
    seller: User.all.sample
  )
end

puts

# Orders

print "Creating orders "

QUANTITIES = [1] * 10 + [2] * 5 + [3] * 3 + (4..20).to_a

150.times do
  print "."
  buyer = User.all.sample
  possible_products = Product.where.not(seller: buyer)

  order = Order.create!(buyer: buyer)
  rand(1..5).times do
    order.order_items.create!(product: possible_products.to_a.sample, quantity: QUANTITIES.sample)
  end
end

puts

print "Updating product quantities "

REMAINING_QUANTITIES = [0] * 40 + (1..100).to_a

Product.all.each do |product|
  print "."
  ordered_quantity = OrderItem.where(product: product).sum(:quantity)

  total_quantity = ordered_quantity + REMAINING_QUANTITIES.sample
  total_quantity += rand(1..10) if total_quantity.zero?

  product.update_attributes!(quantity: total_quantity)
end

puts
