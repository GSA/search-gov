require 'resque'

Resque::Failure::Hoptoad.configure do |config|
  config.api_key = '***REMOVED***'
  config.secure = true
end