module Oasis
  FLICKR_API_ENDPOINT = "/api/v1/flickr_profiles.json"
  MRSS_API_ENDPOINT = "/api/v1/mrss_profiles.json"

  def self.subscribe_to_mrss(url)
    params = { url: url }
    post_subscription(mrss_api_url, params)
  end

  def self.subscribe_to_flickr(id, name, profile_type)
    params = { id: id, name: name, profile_type: profile_type }
    post_subscription(flickr_api_url, params)
  end

  def self.host
    Rails.application.secrets.asis[:host]
  end

  private

  def self.mrss_api_url
    "#{host}#{MRSS_API_ENDPOINT}"
  end

  def self.flickr_api_url
    "#{host}#{FLICKR_API_ENDPOINT}"
  end

  def self.post_subscription(endpoint, params)
    response = Net::HTTP.post_form(URI.parse(endpoint), params)
    JSON.parse(response.body)
  rescue Exception => e
    Rails.logger.warn("Trouble posting subscription to #{endpoint} with params: #{params}: #{e}")
  end
end
