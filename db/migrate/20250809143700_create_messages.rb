class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.text :content, null: false
      t.jsonb :metadata, default: {}
      t.references :workout_plan, foreign_key: true

      t.timestamps
    end
  end
end
