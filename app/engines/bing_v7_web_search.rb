# frozen_string_literal: true

class BingV7WebSearch < BingSearch
  API_ENDPOINT = '/v7.0/search'
  API_HOST = 'https://api.bing.microsoft.com'

  self.api_endpoint = API_ENDPOINT
  self.api_cache_namespace = 'bing_v7'
  self.response_parser_class = BingWebResponseParser

  def self.api_host
    API_HOST
  end

  def hosted_subscription_key
    @hosted_subscription_key ||=
      Rails.application.secrets.bing_v7[:web_subscription_id].freeze
  end
end
