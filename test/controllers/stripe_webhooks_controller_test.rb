require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get stripe_webhooks_create_url
    assert_response :success
  end
end
