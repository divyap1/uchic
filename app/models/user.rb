class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :orders, inverse_of: :buyer
  validates :name, presence: true
  validates :address, presence: true
  validates :rating, numericality: {
    greater_than_or_equal_to: 0.0,
    less_than_or_equal_to: 5.0,
    allow_blank: true
  }
end
