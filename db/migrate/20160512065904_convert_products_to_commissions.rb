class ConvertProductsToCommissions < ActiveRecord::Migration
  def change
    remove_column :products, :quantity, :integer
    add_column :products, :state, :string, default: "discussion"
    add_column :products, :allow_copies, :boolean, default: true
    add_column :products, :allow_similar, :boolean, default: true
    add_column :products, :buyer_id, :integer
    rename_table :products, :commissions

    rename_column :order_items, :product_id, :commission_id
  end
end
