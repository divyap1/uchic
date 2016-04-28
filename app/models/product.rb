class Product < ActiveRecord::Base
  belongs_to :seller, class_name: 'User'
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :buyers, through: :orders

  validates :seller, presence: true
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  #For searching by name
  scope :starts_with, -> (name) { where("name like ?", "#{name}%")}

end
