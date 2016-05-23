class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :commissions_as_seller, foreign_key: :seller_id, class_name: "Commission"
  has_many :commissions_as_buyer, foreign_key: :buyer_id, class_name: "Commission"
  has_many :orders, foreign_key: :buyer_id
  has_many :reviews
  has_many :notifications

  has_many :friendships
  has_many :followings, :through => :friendships

  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "following_id"
  has_many :followers, :through => :inverse_friendships, :source => :user

  validates :name, presence: true
  validates :username, presence: true
  validates :address, presence: true

  has_attached_file :profile_picture, default_url: "/images/no-profile-picture.png", styles: { thumb:'128x128#' }
  validates_attachment_content_type :profile_picture, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_attached_file :profile_background, default_url: "/images/no-profile-bg.jpg", styles: { thumb:'128x128#' }
  validates_attachment_content_type :profile_background, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  scope :contains, -> (search) { where("name like ? OR username like ?", "#{search}%", "#{search}%")}

  def first_name
    name.split(/\s+/).first
  end

  def country_name
    country_name = ISO3166::Country[country]
    return "Country Unknown" unless country_name

    country_name.translations[I18n.locale.to_s] || country_name.name
  end

  def rating
    reviews.average(:rating) || 0
  end
end
