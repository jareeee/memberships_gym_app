class WorkoutPlan < ApplicationRecord
  belongs_to :user
  has_many :plan_exercises, dependent: :destroy
  has_many :messages, dependent: :nullify

  validates :title, presence: true
  validates :focus_area, inclusion: { in: %w[upper_body lower_body full_body cardio strength flexibility] }, allow_blank: true

  scope :by_focus_area, ->(area) { where(focus_area: area) }
  scope :recent, -> { order(created_at: :desc) }
end
