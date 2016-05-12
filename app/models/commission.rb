class Commission < ActiveRecord::Base
  belongs_to :seller, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  belongs_to :category

  has_one :order_item
  has_many :pictures

  validates :state, inclusion: { in: ["discussion", "accepted", "paid", "in_progress", "shipped"] }
  validates :seller, presence: true
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }

  #For searching by name
  scope :contains, -> (name) { where("name like ?", "%#{name}%")}

  def order
    order_item.order
  end
end
