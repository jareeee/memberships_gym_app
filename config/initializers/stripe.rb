# config/initializers/stripe.rb
require "stripe"

Stripe.api_key = Rails.application.credentials.stripe[:secret_key]