class AddCommissionIdToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :commission_id, :integer
  end
end
