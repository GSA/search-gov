# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
UsasearchRails3::Application.initialize!

APP_EMAIL_ADDRESS = "***REMOVED***"

AWS_ACCESS_KEY_ID = "***REMOVED***"
AWS_SECRET_ACCESS_KEY = "***REMOVED***"
AWS_BUCKET_NAME = "***REMOVED***"

CalendarDateSelect.format = :american

Twitter.configure do |config|
  config.consumer_key = "***REMOVED***"
  config.consumer_secret = "***REMOVED***"
  config.oauth_token = "***REMOVED***"
  config.oauth_token_secret = "***REMOVED***"
end

FlickRaw.api_key = "***REMOVED***"
FlickRaw.shared_secret = "***REMOVED***"
