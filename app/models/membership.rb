class Membership < ApplicationRecord
  belongs_to :user
  enum status: {
    active: 'active',
    expired: 'expired'
  }

  scope :active, -> { where(status: :active) }
  scope :expired, -> { where(status: :expired) }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
