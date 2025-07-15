class AddPhoneAndAddressToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :phone, :string
    add_column :users, :address, :text
  end
end
