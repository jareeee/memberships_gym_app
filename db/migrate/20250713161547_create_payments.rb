# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :transaction_id
      t.string :status
      t.string :membership_duration

      t.timestamps
    end
  end
end
