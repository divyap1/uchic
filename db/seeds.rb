# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

def create_categories(category_name, parent_id, sub_categories = nil)
  category = Category.create! :name => category_name, :parent_id => parent_id
  return if sub_categories.nil?

  sub_categories.each do |sub|
    create_categories(sub[:name], category.id)
  end
end

# Delete existing data
Category.delete_all
User.delete_all
Product.delete_all
Order.delete_all
OrderItem.delete_all

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
  "Artworks" => [
    { name: "Painting", price: 50..400 },
    { name: "Sculpture", price: 80..500 },
    { name: "Print", price: 15..150 },
    { name: "Poster", price: 5..25 }
  ],
  "Clothing" => [
    { name: "T-shirt", price: 15..50 },
    { name: "Jersey", price: 30..90 },
    { name: "Hoodie", price: 40..100 },
    { name: "Shirt", price: 50..120 },
    { name: "Trousers", price: 50..150 },
    { name: "Socks", price: 10..50 },
    { name: "Skirt", price: 30..120 },
    { name: "Dress", price: 90..400 }
  ],
  "Accessories" => [
    { name: "Scarf", price: 20..50 },
    { name: "Hat", price: 25..80 },
    { name: "Gloves", price: 20..70 }
  ],
  "Jewelry" => [
    { name: "Ring", price: 60..600 },
    { name: "Necklace", price: 80..800 },
    { name: "Earrings", price: 70..500 }
  ],
  "Miscellaneous" => [
    { name: "Loot Box", price: 10..80 },
    { name: "Mystery Gift", price: 10..80 }
  ]
}

# creates categories in system
all_items = Category.create! :name => "All Items"
PRODUCT_TYPES.each_key do |category|
  create_categories(category, all_items.id, PRODUCT_TYPES[category])
end

ALL_PRODUCT_TYPES = PRODUCT_TYPES.values.flatten

PRODUCT_NAMES = [
  50.times.map { Faker::App.name },
  50.times.map { Faker::Team.creature.singularize },
  100.times.map { Faker::Book.title },
  10.times.map { Faker::Book.genre },
  50.times.map { Faker::Hipster.word },
  50.times.map { Faker::StarWars.character }
].flatten

100.times do
  print "."
  type_info = ALL_PRODUCT_TYPES.sample
  product_category = Category.find_by(name: type_info[:name])

  product_category.products.create!(
    name: "#{PRODUCT_NAMES.sample.titleize} #{product_category.name}",
    description: Faker::Hipster.paragraph,
    price: type_info[:price].to_a.sample + [0, 0.50, 0.99].sample,
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
