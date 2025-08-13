# frozen_string_literal: true
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :memberships, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :check_ins, dependent: :destroy
  has_many :workout_plans, dependent: :destroy
  has_many :messages, dependent: :destroy

  WEEKLY_AI_LIMIT = 10

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first
    user ||= User.create(
      full_name: data['name'],
      email: data['email'],
      password: Devise.friendly_token[0..20]
    )

    user
  end

  def age
    return unless birthdate

    today = Date.current
    today.year - birthdate.year - ((today.month > birthdate.month || (today.month == birthdate.month && today.day >= birthdate.day)) ? 0 : 1)
  end

  def has_active_membership?
    memberships.active.where('end_date >= ?', Date.current).exists?
  end

  def monday_for(date)
    date - ((date.wday + 6) % 7)
  end

  def ensure_ai_weekly_period!
    today = Date.current
    current_monday = monday_for(today)
    if ai_weekly_period_start != current_monday
      update_columns(ai_weekly_period_start: current_monday, ai_weekly_uses_count: 0)
    end
  end

  def ai_remaining_uses
    ensure_ai_weekly_period!
    WEEKLY_AI_LIMIT - ai_weekly_uses_count.to_i
  end

  def ai_usage_allowed?
    ai_remaining_uses > 0
  end

  def increment_ai_usage!
    ensure_ai_weekly_period!
    increment!(:ai_weekly_uses_count)
  end
end
