class CreatePlanExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_exercises do |t|
      t.references :workout_plan, null: false, foreign_key: true
      t.string :exercise, null: false
      t.integer :sets
      t.string :reps
      t.integer :rest_seconds
      t.string :tempo
      t.jsonb :modifiers, default: {}

      t.timestamps
    end
  end
end
