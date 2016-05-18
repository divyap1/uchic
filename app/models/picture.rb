class Picture < ActiveRecord::Base
  belongs_to :commission

  has_attached_file :picture, default_url: "/images/products/default.png",
    styles: {thumb: '128x128#', small: '256x256#', medium: '512x512#'}
  crop_attached_file :picture
  validates_attachment_content_type :picture, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
