class AddPaymentDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :card_type, :string
    add_column :users, :card_name, :string
    add_column :users, :card_number, :string, limit:19
    add_column :users, :expiration_month, :integer
    add_column :users, :expiration_year, :integer
    add_column :users, :security_code, :integer, limit:4
  end
end
