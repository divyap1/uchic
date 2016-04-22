# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Users

fritz = User.create!(
  name: "Fritz Chesterton",
  address: "35 Stout St\nThorndon\nWellington",
  email: "fritz@maily.com",
  password: "0hsosecret",
  password_confirmation: "0hsosecret"
)

anselm = User.create!(
  name: "Anselm Costantini",
  address: "44 Strasbourge St\nMartinborough",
  email: "cost0100@maily.com",
  password: "0hsosecret",
  password_confirmation: "0hsosecret"
)

# Products

loot_box1 = Product.create!(
  name: "Mystery Loot Box",
  description: "A random collection of cool stuff.",
  price: 10.50,
  quantity: 10,
  seller: fritz
)
loot_box2 = Product.create!(
  name: "Magical Loot Box",
  description: "An awesome random collection of cool stuff.",
  price: 49.99,
  quantity: 10,
  seller: fritz
)

goku_beanie = Product.create!(name: "Goku Beanie", price: 15.00, quantity: 20, seller: anselm)
piccolo_tee = Product.create!(name: "Piccolo T-shirt", price: 20.00, quantity: 15, seller: anselm)
krillin_badge = Product.create!(name: "Krillin Badge", price: 0.50, quantity: 100, seller: anselm)

# Orders

loot_box_order = Order.create!(buyer: anselm)
loot_box_order.order_items.create!(product: loot_box1, quantity: 2)
loot_box_order.order_items.create!(product: loot_box2, quantity: 1)

goku_order = Order.create!(buyer: fritz)
goku_order.order_items.create!(product: goku_beanie, quantity: 1)

krillin_order = Order.create!(buyer: fritz)
krillin_order.order_items.create!(product: krillin_badge, quantity: 20)
