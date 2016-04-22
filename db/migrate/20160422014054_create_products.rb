class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :description
      t.float :price, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :seller_id, null: false

      t.timestamps null: false
    end
  end
end
