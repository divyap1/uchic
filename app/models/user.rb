class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :commissions_as_seller, foreign_key: :seller_id, class_name: "Commission"
  has_many :commissions_as_buyer, foreign_key: :buyer_id, class_name: "Commission"
  has_many :orders, foreign_key: :buyer_id
  has_many :reviews
  
  has_many :friendships
  has_many :friends, :through => :friendships

  validates :name, presence: true
  validates :address, presence: true
  validates :rating, numericality: {
    greater_than_or_equal_to: 0.0,
    less_than_or_equal_to: 5.0,
    allow_blank: true
  }

  has_attached_file :profile_picture, default_url: "/images/no-profile-picture.png"
  validates_attachment_content_type :profile_picture, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  scope :contains, -> (search) { where("name like ? OR email like ?", "%#{search}%", "%#{search}%")}  

  def first_name
    name.split(/\s+/).first
  end
end
