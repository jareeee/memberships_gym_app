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
end
