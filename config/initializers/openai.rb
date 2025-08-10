OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.dig(:OPENAI_ACCESS_TOKEN)
end