class CreateMessageThreads < ActiveRecord::Migration
  def change
    create_table :message_threads do |t|
      t.integer :commission_id
      t.integer :seller_id
      t.integer :buyer_id

      t.timestamps null: false
    end
  end
end
