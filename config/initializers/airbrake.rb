Airbrake.configure do |config|
  config.api_key = '***REMOVED***'
  config.ignore << ActionController::MethodNotAllowed
  config.ignore << ActionController::UnknownHttpMethod
  config.ignore << REXML::ParseException
  config.ignore << EOFError
end
