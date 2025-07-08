class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.date :purchase_date
      t.string :membership_type
      t.string :status, default: 'inactive'

      t.timestamps
    end
  end
end
