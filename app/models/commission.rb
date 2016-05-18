class Commission < ActiveRecord::Base
  STATES = {
    "discussion" => "Discussion",
    "accepted" => "Accepted; awaiting payment",
    "paid" => "Paid",
    "in_progress" => "Payment received; in progress",
    "shipped" => "Shipped"
  }

  delegate :partner, to: :message_thread

  before_save :reset_acceptance

  belongs_to :seller, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  belongs_to :category

  has_one :message_thread
  has_many :pictures

  validates :state, inclusion: { in: STATES.keys }
  validates :seller, presence: true
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }

  #For searching by name
  scope :contains, -> (name) { where("name like ?", "%#{name}%")}

  scope :publicly_visible, -> { where(public: true) }

  STATES.each_key.with_index do |state, index|
    scope state, -> { where(state: state) }

    define_method(state + "?") { self.state == state }
  end

  def private?
    !public?
  end

  def accepted_by?(user)
    user == buyer ? accepted_by_buyer? : accepted_by_seller?
  end

  def accept!(user)
    if user == buyer
      update_attributes!(accepted_by_buyer: true)
    else
      update_attributes!(accepted_by_seller: true)
    end

    if accepted_by_buyer? && accepted_by_seller?
      update_attributes!(state: "accepted")
    end
  end

  def reset_acceptance
    unless changed.all? { |a| a == "accepted_by_buyer" || a == "accepted_by_seller" }
      self.accepted_by_buyer = false
      self.accepted_by_seller = false

      true # Returning false makes save fail
    end
  end
end
