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

  def self.create_index
    index = ENV.fetch('SEARCHELASTIC_INDEX')

    template_generator = SearchElastic::Template.new("*#{index}*")

    self.client.indices.put_template(
      body: template_generator.body,
      create: true,
      include_type_name: false,
      name: :search_elastic,
      order: 0
    )

    repo = SearchElastic::DocumentRepository.new
    repo.create_index!(index:, include_type_name: true)
  end
end
