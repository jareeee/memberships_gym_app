class PlanExercise < ApplicationRecord
  belongs_to :workout_plan

  validates :exercise, presence: true
  validates :sets, presence: true, numericality: { greater_than: 0 }
  validates :rest_seconds, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  scope :by_exercise_type, ->(type) { where("modifiers @> ?", { type: type }.to_json) }
end
