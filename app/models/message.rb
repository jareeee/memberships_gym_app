class Message < ApplicationRecord
  belongs_to :user
  belongs_to :workout_plan, optional: true

  enum role: {
    user: 0,
    assistant: 1,
    system: 2
  }

  validates :content, presence: true
  validates :role, presence: true

  scope :for_chat, -> { order(:created_at) }
  scope :by_role, ->(role) { where(role: role) }
end
