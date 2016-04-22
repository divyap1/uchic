class Product < ActiveRecord::Base
  belongs_to :seller, class_name: 'User'
  has_many :buyers, class_name: 'User'
  has_many :order_items   
end
