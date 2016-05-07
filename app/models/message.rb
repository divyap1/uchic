class Message < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :sender, :receiver, :message, presence: true

  scope(:between, lambda do |user, partner|
    where(
      '(sender_id=? AND receiver_id=?) OR (sender_id=? AND receiver_id=?)',
      user.id, partner.id, partner.id, user.id
    )
  end)
end
