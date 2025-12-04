# frozen_string_literal: true

require 'search_elastic/index_create'

module ES
  ES_CONFIG = Rails.application.config_for(:elasticsearch_client).freeze

  def self.client
    @client ||= Elasticsearch::Client.new(
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

  @index_creator = SearchElastic::IndexCreate.new(
    service_name: 'ELASTICSEARCH',
    index_name: ENV.fetch('SEARCHELASTIC_INDEX'),
    shards: ENV.fetch('SEARCHELASTIC_INDEX_SHARDS', 1),
    replicas: ENV.fetch('SEARCHELASTIC_INDEX_REPLICAS', 1)
  )

  def self.create_index
    @index_creator.create_or_update_index(self.client)
  end

end
