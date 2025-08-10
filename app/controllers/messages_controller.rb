class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    body = params.require(:content)
    plan = GenerateWorkoutPlanJob.perform_later(current_user.id, body)
    redirect_to workout_plans_path, notice: "Lagi dibuat, nanti auto muncul."
  end
end
