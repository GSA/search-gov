module BingV5HostedSubscriptionKey
  BING_V5_SUBSCRIPTION_KEY = Rails.application.secrets.hosted_azure['v5_account_key'].freeze

  def hosted_subscription_key
    BING_V5_SUBSCRIPTION_KEY
  end
end
