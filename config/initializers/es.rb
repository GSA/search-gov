# frozen_string_literal: true

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

  def self.create_index
    index_name = ENV.fetch('SEARCHELASTIC_INDEX') do
      raise KeyError, 'SEARCHELASTIC_INDEX must be set in environment'
    end

    template_generator = SearchElastic::Template.new("*#{index_name}*")

    if self.client.indices.exists?(index: index_name)
      Rails.logger.info { "Index #{index_name} already exists in Elasticsearch. Updating mapping..." }
      self.update_index_mapping(index_name)
    else
      Rails.logger.info { "Creating new Elasticsearch index: #{index_name}" }
      self.client.indices.put_index_template(
        index_patterns: template_generator.index_patterns,
        template: template_generator.body,
        priority: 0
      )
      repo = SearchElastic::DocumentRepository.new
      repo.create_index!(index: index_name)
    end
  end

  def self.update_index_mapping(index_name)
    mapping_update = {
      properties: {
        domain_name: {
          type: 'text',
          analyzer: 'domain_name_analyzer',
          fields: {
            keyword: {
              type: 'keyword'
            }
          }
        }
      }
    }

    self.client.indices.put_mapping(
      index: index_name,
      body: mapping_update,
      include_type_name: false
    )

    Rails.logger.info { "Successfully updated Elasticsearch mapping for index: #{index_name}" }
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
    # Common reasons include attempting to change an existing field type — handle gracefully.
    if e.message =~ /mapper_parsing_exception|illegal_argument_exception/
      Rails.logger.warn { "Cannot update Elasticsearch domain_name field mapping for #{index_name}: #{e.message}" }
    else
      raise
    end
  end
end
