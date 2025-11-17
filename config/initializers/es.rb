# frozen_string_literal: true

module ES
  ES_CONFIG = Rails.application.config_for(:elasticsearch_client).freeze

  def self.client
    Elasticsearch::Client.new(
      ES_CONFIG.merge(
        # hosts: ['http://elasticsearch7:9200'], # TODO: REMOVE
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

  def self.create_index
    index_name = ENV.fetch('SEARCHELASTIC_INDEX')

    template_generator = SearchElastic::Template.new("*#{index_name}*")

    self.client.indices.put_template(
      body: template_generator.body,
      create: true,
      include_type_name: false,
      name: index_name,
      order: 0
    )

    repo = SearchElastic::DocumentRepository.new
    repo.create_index!(index: index_name, include_type_name: true)
  end
end
