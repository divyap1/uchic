class ChangePictureProductToCommission < ActiveRecord::Migration
  def change
    rename_column :pictures, :product_id, :commission_id
  end
end
