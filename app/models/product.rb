class Product < ActiveRecord::Base
  belongs_to :seller, class_name: 'User'
  belongs_to :category
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :buyers, through: :orders
  has_many :pictures

  validates :seller, presence: true
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  #For searching by name
  scope :contains, -> (name) { where("name like ?", "%#{name}%")}  

end
