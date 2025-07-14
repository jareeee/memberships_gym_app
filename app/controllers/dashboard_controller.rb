
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @membership = current_user.memberships.active.first
    @recent_check_ins = current_user.check_ins.includes(:gym_location).order(check_in_timestamp: :desc).limit(5)
  end
end