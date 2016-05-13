class MessageThread < ActiveRecord::Base
  belongs_to :commission
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  belongs_to :deleted_by, class_name: "User"
  has_many :messages

  validates :buyer, :seller, presence: true

  scope :related_to, ->(user) {
    where("buyer_id=? OR seller_id=?", user.id, user.id)
      .where("deleted_by_id IS NULL OR deleted_by_id=?", user.id)
      .order(created_at: :desc)
  }

  def partner(user)
    seller == user ? buyer : seller
  end

  def detailed_attributes
    attributes.merge(
      seller_name: seller.name,
      messages: messages.map(&:detailed_attributes)
    )
  end
end
