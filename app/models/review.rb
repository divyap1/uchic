class Review < ActiveRecord::Base
  belongs_to :reviewer, class_name: "User"
  belongs_to :user, class_name: "User"
end