class AddReviewIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :review_id, :integer
  end
end
