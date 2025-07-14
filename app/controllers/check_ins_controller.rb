# app/controllers/check_ins_controller.rb
class CheckInsController < ApplicationController
  before_action :authenticate_user!

  def new

  end

  def create
    qr_identifier = params[:qr_data]
    location = GymLocation.find_by(qr_code_identifier: qr_identifier)

    unless location
      render json: { success: false, message: 'QR Code not valid.' }, status: :unprocessable_entity
      return
    end

    if current_user.check_ins.where('check_in_timestamp > ?', 5.minutes.ago).exists?
      render json: { success: false, message: 'You already checked in a while ago.' }, status: :conflict
      return
    end

    check_in = current_user.check_ins.create(
      gym_location: location,
      check_in_timestamp: Time.current
    )

    if check_in.persisted?
      render json: { success: true, message: 'Check-in success!' }
    else
      render json: { success: false, message: 'Failed to save check-in.' }, status: :internal_server_error
    end
  end
end
