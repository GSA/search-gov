# Datadog API client used to send exception data to Datadog.
datadog_api_config = Rails.application.secrets.datadog

if datadog_api_config[:api_enabled]
  datadog_api_client = Dogapi::Client.new(
    datadog_api_config[:api_key],
    datadog_api_config[:application_key]
  )
  Rails.application.config.middleware.use ExceptionNotification::Rack,
  datadog: {
    client: datadog_api_client
  }
end
