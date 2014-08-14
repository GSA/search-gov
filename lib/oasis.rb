module Oasis
  INSTAGRAM_API_ENDPOINT = 'http://localhost:3000/api/v1/instagram_profiles.json'
  FLICKR_API_ENDPOINT = 'http://localhost:3000/api/v1/flickr_profiles.json'

  def self.subscribe_to_instagram(id, username)
    params = { id: id, username: username }
    post_subscription(INSTAGRAM_API_ENDPOINT, params)
  end

  def self.subscribe_to_flickr(id, name, profile_type)
    params = { id: id, name: name, profile_type: profile_type }
    post_subscription(FLICKR_API_ENDPOINT, params)
  end

  private
  def self.post_subscription(endpoint, params)
    Net::HTTP.post_form(URI.parse(endpoint), params)
  rescue Exception => e
    Rails.logger.warn("Trouble posting subscription to #{endpoint} with params: #{params}: #{e}")
  end

end
