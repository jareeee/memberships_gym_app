# frozen_string_literal: true

class MembershipsService
  def initialize(user)
    @user = user
    @url = Rails.application.routes.url_helpers
  end

  def create_session(price_id)
    Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [
        {
          price: price_id,
          quantity: 1
        },
        {
          price_data: {
            currency: 'idr',
            product_data: { name: 'Admin Fees' },
            unit_amount: 100_000
          },
          quantity: 1
        }
      ],
      mode: 'subscription',
      success_url: "#{@url.memberships_paid_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: @url.root_url,
      customer_email: @user.email
    )
  end
end
