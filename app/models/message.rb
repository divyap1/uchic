class Message < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :message_thread

  validates :sender, :receiver, :message, :message_thread, presence: true

  scope(:between, lambda do |user, partner|
    where(
      '(sender_id=? AND receiver_id=?) OR (sender_id=? AND receiver_id=?)',
      user.id, partner.id, partner.id, user.id
    ).order(:created_at)
  end)

  def self.first_in_each_thread(user)
    sender_messages = where(sender: user).group(:receiver_id).having('created_at = MAX(created_at)')
    receiver_messages = where(receiver: user).group(:sender_id).having('created_at = MAX(created_at)')

    (sender_messages + receiver_messages)
      .uniq { |message| Set.new([message.sender_id, message.receiver_id]) }
      .sort { |a, b| b.created_at <=> a.created_at }
  end

  def detailed_attributes
    attributes.merge(sender_name: sender.name, receiver_name: receiver.name)
  end

  def partner(user)
    sender == user ? receiver : sender
  end
end
