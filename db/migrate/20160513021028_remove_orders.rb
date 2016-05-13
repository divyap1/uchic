class RemoveOrders < ActiveRecord::Migration
  def change
    drop_table :orders
    drop_table :order_items
  end
end
