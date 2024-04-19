FlickRaw.api_key       = ENV['FLICKR_API_KEY']       || Rails.application.secrets.flickr[:api_key]
FlickRaw.shared_secret = ENV['FLICKR_SHARED_SECRET'] || Rails.application.secrets.flickr[:shared_secret]
