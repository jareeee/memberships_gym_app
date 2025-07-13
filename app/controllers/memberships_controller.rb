# frozen_string_literal: true

class MembershipsController < ApplicationController
  def index
    @times = [1, 3, 6, 12]
  end

  def show_payment
    @duration = params[:duration]
    @payment_method = params[:payment_method]
    @membership_price = calculate_price(@duration)
    @taxes = 1000
    @total = @membership_price + @taxes
  end

  def payment
    session = service.create_session(params)

    redirect_to session.url, allow_other_host: true
  end

  def service
    @service = ::MembershipsService.new(current_user)
  end

  def paid
    membership = current_user.memberships.active.first
    return unless membership

    @expiry_date = membership.end_date
    @total_payment = current_user.payments.last.amount
    @duration = current_user.payments.last.membership_duration
  end

  private

  def calculate_price(duration)
    case duration.to_i
    when 1
      100_000
    when 3
      250_000
    when 6
      450_000
    when 12
      800_000
    end
  end
end
