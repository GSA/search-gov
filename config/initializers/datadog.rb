# Datadog API client used to send exception data to Datadog.

if ENV['DATADOG_API_ENABLED']
  datadog_api_client = Dogapi::Client.new(ENV['DATADOG_API_KEY'],ENV['DATADOG_APPLICATION_KEY'])

  Rails.application.config.middleware.use ExceptionNotification::Rack, datadog: { client: datadog_api_client }
else
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
end
