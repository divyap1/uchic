class Commission < ActiveRecord::Base
  STATES = ["discussion", "accepted", "paid", "in_progress", "shipped"]

  delegate :partner, to: :message_thread

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

  scope :publicly_visible, -> { where(public: true) }

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

  def private?
    !public?
  end
end
