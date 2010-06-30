require 'rexml/document'
HoptoadNotifier.configure do |config|
  config.api_key = 'cbe1c27890a51f3829e6476388b3d0c8'
  config.ignore << ActionController::MethodNotAllowed
  config.ignore << ActionController::UnknownHttpMethod
  config.ignore << REXML::ParseException
end
