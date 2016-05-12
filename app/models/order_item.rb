class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :commission

  validates :order, presence: true
  validates :commission, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
end
