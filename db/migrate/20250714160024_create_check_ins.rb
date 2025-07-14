class CreateCheckIns < ActiveRecord::Migration[7.1]
  def change
    create_table :check_ins do |t|
      t.references :user, null: false, foreign_key: true
      t.references :gym_location, null: false, foreign_key: true
      t.datetime :check_in_timestamp

      t.timestamps
    end
  end
end
