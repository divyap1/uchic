class ChangePublicDefault < ActiveRecord::Migration
  def change
    change_column_default(:commissions, :public, true)
  end
end
