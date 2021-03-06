class Notification < ActiveRecord::Base
  STATES = ["product listed", "copy requested", "similar requested", "new requested",
          "request accepted", "counter offer", "payment received", "request denied",
           "item delivered", "new follower", "new review"]

  belongs_to :user
  belongs_to :commission
  belongs_to :about_user, class_name: 'User'
  belongs_to :review

  validates :state, inclusion: { in: STATES }
  validates :user, presence: true
  validates :about_user, presence: true

  has_attached_file :image
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
