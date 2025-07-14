# frozen_string_literal: true

class CreateGymLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :gym_locations do |t|
      t.string :qr_code_identifier
      t.string :branch
      t.string :address

      t.timestamps
    end
  end
end
