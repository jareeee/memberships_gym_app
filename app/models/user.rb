# frozen_string_literal: true
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :memberships, dependent: :destroy

  def active_membership
    memberships.where("end_date >= ?", Date.today).order(end_date: :desc).first
  end

  def membership_active?
    active_membership.present?
  end

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
end
