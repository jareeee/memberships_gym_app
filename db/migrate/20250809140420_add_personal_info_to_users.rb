class AddPersonalInfoToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :birthdate, :date
    add_column :users, :gender, :text
    add_column :users, :height_cm, :integer
    add_column :users, :weight_kg, :decimal, precision: 5, scale: 2
  end
end
