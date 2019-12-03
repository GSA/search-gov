module BingV7HostedSubscriptionKey
  BING_V7_SUBSCRIPTION_KEY = Rails.application.secrets.bing_v7['subscription_id'].freeze

  def hosted_subscription_key
    BING_V7_SUBSCRIPTION_KEY
  end
end
