class Commission < ActiveRecord::Base
  STATES = ["discussion", "accepted", "paid", "in_progress", "shipped"]

  belongs_to :seller, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  belongs_to :category

  has_one :message_thread
  has_many :pictures

  validates :state, inclusion: { in: STATES }
  validates :seller, presence: true
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }

  #For searching by name
  scope :contains, -> (name) { where("name like ?", "%#{name}%")}

  scope :public, -> { where(public: true) }

  alias_method :accepted_by_buyer?, :accepted_by_buyer
  alias_method :accepted_by_seller?, :accepted_by_seller

  STATES.each.with_index do |state, index|
    matching_states = STATES[index..-1]

    scope state, -> { where(state: matching_states) }

    define_method(state + "?") do
      self.state.in?(matching_states)
    end
  end

  def editable?
    discussion? && !accepted_by_seller? && !accepted_by_buyer?
  end

  def detailed_attributes
    attributes.merge(
      message_thread: message_thread.try!(:detailed_attributes)
    )
  end
end
