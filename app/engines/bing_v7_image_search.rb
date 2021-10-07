# frozen_string_literal: true

class BingV7ImageSearch < BingSearch
  API_HOST = 'https://api.cognitive.microsoft.com'
  API_ENDPOINT = '/bing/v7.0/images/search'

  self.api_endpoint = API_ENDPOINT
  self.api_cache_namespace = 'bing_v7'
  self.response_parser_class = BingImageResponseParser

  def self.api_host
    API_HOST
  end

  def hosted_subscription_key
    @hosted_subscription_key ||=
      Rails.application.secrets.bing_v7[:image_subscription_id].freeze
  end
end
