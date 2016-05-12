class MessageThread < ActiveRecord::Base
  belongs_to :commission
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  validates :buyer, :seller, presence: true
end
