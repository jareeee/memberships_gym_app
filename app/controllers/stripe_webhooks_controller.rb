# frozen_string_literal: true

class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.stripe[:webhook_secret]
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      render json: { error: e.message }, status: 400
      return
    end

    if event.type == 'checkout.session.completed'
      session = event.data.object

      user_id = session.metadata.user_id
      membership_duration = session.metadata.membership_duration
      user = User.find(user_id)

      if user
        Payment.create!(
          user: user,
          amount: session.amount_total / 100,
          status: 'success',
          transaction_id: session.id,
          membership_duration: "#{membership_duration} month"
        )

        Membership.create!(
          user: user,
          start_date: Date.today,
          end_date: Date.today + membership_duration.to_i.month,
          purchase_date: Date.today,
          membership_type: "#{membership_duration} month",
          status: 'active'
        )
      end
    end

    render json: { message: 'success' }, status: 200
  end
end
