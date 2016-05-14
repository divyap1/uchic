class Picture < ActiveRecord::Base
  belongs_to :commission

  has_attached_file :picture, default_url: "/images/products/default.png"
  validates_attachment_content_type :picture, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
