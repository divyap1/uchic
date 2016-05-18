class Picture < ActiveRecord::Base
  belongs_to :commission

  has_attached_file :picture, default_url: "/images/products/default.png",
    styles: {thumb: "100x100#", medium: "200x200#"}

  validates_attachment_content_type :picture, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
