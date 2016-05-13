class Category < ActiveRecord::Base
  has_ancestry
  has_many :commissions, foreign_key: :category_id
end
