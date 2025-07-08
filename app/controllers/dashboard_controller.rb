
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # @membership = current_user.memberships.order(end_date: :desc).first
    # @recent_check_ins = current_user.check_ins.order(check_in_timestamp: :desc).limit(5)
  end
end