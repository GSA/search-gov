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

    self.client.indices.put_template(
      body: template_generator.body,
      # create: true,
      include_type_name: false,
      name: index_name,
      order: 0
    )

    if self.client.indices.exists?(index: index_name)
      Rails.logger.info { "Index #{index_name} already exists. Updating mapping..." }
      self.update_index_mapping(index_name)
    else
      Rails.logger.info { "Creating new index: #{index_name}" }
      repo = SearchElastic::DocumentRepository.new
      repo.create_index!(index: index_name, include_type_name: false)
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

    Rails.logger.info { "Successfully updated mapping for index: #{index_name}" }
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
    # Common reasons include attempting to change an existing field type — handle gracefully.
    if e.message =~ /mapper_parsing_exception|illegal_argument_exception/
      Rails.logger.warn { "Cannot update domain_name field mapping for #{index_name}: #{e.message}" }
    else
      raise
    end
  end

  def self.check_current_mapping(index_name)
    begin
      mapping = self.client.indices.get_mapping(index: index_name)
      Rails.logger.info "Current mapping for #{index_name}: #{mapping.to_json}"
      mapping
    rescue => e
      Rails.logger.error "Failed to get mapping: #{e.message}"
      nil
    end
  end
end
