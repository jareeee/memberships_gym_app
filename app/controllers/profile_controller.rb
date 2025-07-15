class ProfileController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def edit

  end

  def update
    if current_user.update(user_params)
      redirect_to profile_path, notice: 'Profile updated successfully!'
    else
      render :show, alert: 'Failed to update profile.'
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :phone, :address)
  end
end
