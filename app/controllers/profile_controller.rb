class ProfileController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def edit
  end

  def update
    if current_user.update(user_params)
      flash.now[:notice] = "Profile updated successfully"
    else
      flash.now[:alert] = "Failed to update profile"
    end
    redirect_to edit_profile_path, notice: flash[:notice], alert: flash[:alert]
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :phone, :address, :birthdate, :gender, :height_cm, :weight_kg)
  end
end
