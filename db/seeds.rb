# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

def create_categories(category_name, parent_id, sub_categories = nil)
  category = Category.create! :name => category_name, :parent_id => parent_id
  return if sub_categories.nil?

  sub_categories.each do |sub|
    create_categories(sub[:name], category.id)
  end
end

def probably_true
  ([true] * 10 + [false] * 3).sample
end

def probably_false
  !probably_true
end

# Delete existing data
Category.delete_all
User.delete_all
Commission.delete_all
MessageThread.delete_all

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
    username: Faker::Internet.user_name(name),
    password: "0hsosecret",
    password_confirmation: "0hsosecret",
    country: "NZ"
  )
end

puts

# Commissions

# category => commission types (categories are not yet used)
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

sellers = User.all.sample(25)
buyers = User.all - sellers.sample(15)

ALL_PRODUCT_TYPES = PRODUCT_TYPES.values.flatten

PRODUCT_NAMES = [
  50.times.map { Faker::App.name },
  50.times.map { Faker::Team.creature.singularize },
  100.times.map { Faker::Book.title },
  10.times.map { Faker::Book.genre },
  50.times.map { Faker::Hipster.word },
  50.times.map { Faker::StarWars.character },
  50.times.map { "Any" }
].flatten

# Suggested commissions

print "Creating suggested commissions "

100.times do
  print "."
  type_info = ALL_PRODUCT_TYPES.sample
  commission_category = Category.find_by(name: type_info[:name])

  commission_category.commissions.create!(
    name: "#{PRODUCT_NAMES.sample.titleize} #{commission_category.name}",
    description: Faker::Hipster.paragraph,
    price: type_info[:price].to_a.sample + [0, 0.50, 0.99].sample,
    seller: sellers.sample,
    state: "shipped",
    public: true,
    allow_copies: probably_true,
    allow_similar: probably_true
  )
end

puts

# Ongoing commissions

print "Creating ongoing commissions "

75.times do
  print "."

  type_info = ALL_PRODUCT_TYPES.sample
  commission_category = Category.find_by(name: type_info[:name])

  seller = sellers.sample
  buyer = buyers.shuffle.find { |buyer| buyer.id != seller.id }

  commission = commission_category.commissions.create!(
    name: "#{PRODUCT_NAMES.sample.titleize} #{commission_category.name}",
    description: Faker::Hipster.paragraph,
    price: type_info[:price].to_a.sample + [0, 0.50, 0.99].sample,
    seller: seller,
    buyer: buyer,
    state: Commission::STATES.keys.sample,
    public: [true, false].sample,
    allow_copies: probably_false,
    allow_similar: probably_false
  )

  MessageThread.create!(
    commission: commission,
    buyer: buyer,
    seller: seller,
  )

  if commission.accepted?
    commission.update_attributes!(accepted_by_buyer: true, accepted_by_seller: true)
  else
    commission.update_attributes!([
      { accepted_by_buyer: true },
      { accepted_by_seller: true },
      {}
    ].sample)
  end
end

puts

# Add reviews

users = User.all.sample(25)
reviewers = User.all - users.sample(15)

COMMENTS = [
  "Geat!", "Good service", "Thanks for the product!", "Loved it",
  "Great seller", "A++!", "Really happy", "I really like the product"
]

print "Creating reviews "

100.times do
  print "."

  user = users.sample
  reviewer = reviewers.shuffle.find { |reviewer| reviewer.id != user.id }

  user.reviews.create(
    reviewer: reviewer,
    user: user, 
    rating: 1 + rand(5),
    comment: COMMENTS.sample
  )
end