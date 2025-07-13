# app/controllers/check_ins_controller.rb
class CheckInsController < ApplicationController
  before_action :authenticate_user!

  def new 

  end

  def create
    # Ambil data unik dari QR code
    qr_identifier = params[:qr_data] 

    # 1. Validasi QR Code (contoh)
    location = GymLocation.find_by(qr_code_identifier: qr_identifier)

    unless location
      render json: { success: false, message: "QR Code tidak valid." }, status: :unprocessable_entity
      return
    end

    # 2. (Opsional) Cek agar tidak double check-in dalam waktu dekat
    if current_user.check_ins.where("check_in_timestamp > ?", 5.minutes.ago).exists?
      render json: { success: false, message: "Anda sudah melakukan check-in beberapa saat lalu." }, status: :conflict
      return
    end

    # 3. Buat record check-in jika semua validasi lolos
    check_in = current_user.check_ins.create(
      gym_location: location,
      check_in_timestamp: Time.current
    )

    if check_in.persisted?
      render json: { success: true, message: "Check-in berhasil!" }
    else
      render json: { success: false, message: "Gagal menyimpan check-in." }, status: :internal_server_error
    end
  end
end