class Category < ActiveRecord::Base
  has_ancestry
  has_many: :products, foreign_key: :category_id
end
