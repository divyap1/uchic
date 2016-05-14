class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :about_user_id
      t.attachment :image
      t.string :state

      t.timestamps null: false
    end
  end
end
