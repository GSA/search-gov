# Load the rails application
require File.expand_path('../application', __FILE__)

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
