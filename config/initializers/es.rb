# frozen_string_literal: true

module ES
  ES_CONFIG = Rails.application.config_for(:elasticsearch_client).freeze

  def self.client
    Elasticsearch::Client.new(
      ES_CONFIG.merge(
        randomize_hosts: true,
        retry_on_failure: true,
        reload_connections: false,
        reload_on_failure: false,
        transport_options: {
          ssl: {
            verify: false
          }
        },
        logger: Rails.logger
      )
    )
  end
end
