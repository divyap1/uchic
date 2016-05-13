class AddExtraFieldsToCommission < ActiveRecord::Migration
  def change
    add_column :commissions, :accepted_by_buyer, :boolean, default: false
    add_column :commissions, :accepted_by_seller, :boolean, default: false
    add_column :commissions, :public, :boolean, default: false
  end
end
