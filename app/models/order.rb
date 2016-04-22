class Order < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User'
  has_many :order_items

  validates :buyer, presence: true
end
