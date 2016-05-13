class Commission < ActiveRecord::Base
  STATES = ["discussion", "accepted", "paid", "in_progress", "shipped"]

  belongs_to :seller, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  belongs_to :category

  has_one :order_item
  has_one :message_thread
  has_many :pictures

  validates :state, inclusion: { in: STATES }
  validates :seller, presence: true
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }

  #For searching by name
  scope :contains, -> (name) { where("name like ?", "%#{name}%")}

  STATES.each do |state|
    define_method(state + "?") do
      self.state == state
    end
  end

  def editable?
    discussion? && !accepted_by_seller? && !accepted_by_buyer?
  end

  def accepted_by_seller?
    false
  end

  def accepted_by_buyer?
    false
  end

  def order
    order_item.order
  end

  def detailed_attributes
    attributes.merge(
      message_thread: message_thread.try!(:detailed_attributes)
    )
  end
end
