class CreateWorkoutPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :workout_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :summary
      t.jsonb :notes, default: {}
      t.string :focus_area
      t.jsonb :meta, default: {}

      t.timestamps
    end
  end
end
