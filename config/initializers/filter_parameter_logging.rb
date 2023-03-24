# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]

# SRCH-3929: Filter the exact 'q' parameter for sayt searches, filter potentially sensitive
# information from the 'query' parameter.
Rails.application.config.filter_parameters += [ /\Aq\z/ ]
Rails.application.config.filter_parameters += [->(k, v) { 
  v&.gsub!(v, Redactor.redact(v)) if /query/.match?(k)
}]
