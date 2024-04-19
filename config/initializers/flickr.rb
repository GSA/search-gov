FlickRaw.api_key       = ENV['FLICKR_API_KEY']       || Rails.application.secrets.dig(:flickr, :api_key)
FlickRaw.shared_secret = ENV['FLICKR_SHARED_SECRET'] || Rails.application.secrets.dig(:flickr, :shared_secret)
