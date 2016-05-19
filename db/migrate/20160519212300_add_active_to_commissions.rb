class AddActiveToCommissions < ActiveRecord::Migration
  def change
    add_column :commissions, :active, :bool, default:true
  end
end
