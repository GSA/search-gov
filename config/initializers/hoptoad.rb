HoptoadNotifier.configure do |config|
  config.api_key = '***REMOVED***'
  config.ignore << ActionController::MethodNotAllowed  
end
