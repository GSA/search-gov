# frozen_string_literal: true

class OpenSearch::Indexer
  def self.create_index
    index_name = ENV.fetch('OPENSEARCH_SEARCH_INDEX')

    if OPENSEARCH_CLIENT.indices.exists?(index: index_name)
      Rails.logger.info { "Index #{index_name} already exists in OpenSearch. Updating mapping..." }
      update_index_mapping(index_name)
    else
      Rails.logger.info { "Creating new OpenSearch index: #{index_name}" }
      template_generator = OpenSearch::Template.new("*#{index_name}*")
      OPENSEARCH_CLIENT.indices.put_template(
        body: template_generator.body,
        include_type_name: false,
        name: index_name,
        order: 0
      )
      repo = OpenSearch::DocumentRepository.new
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

    if OPENSEARCH_CLIENT.indices.exists?(index: index_name)
      OPENSEARCH_CLIENT.indices.put_mapping(
        index: index_name,
        body: mapping_update,
        include_type_name: false
      )
      Rails.logger.info { "Successfully updated OpenSearch mapping for index: #{index_name}" }
    else
      Rails.logger.warn { "Cannot update OpenSearch mapping for index: #{index_name} (index does not exist)" }
    end
  rescue OpenSearch::Transport::Transport::Errors::BadRequest => e
    Rails.logger.warn { "Cannot update OpenSearch domain_name field mapping for #{index_name}: #{e.message}" }
  end

  private_class_method :update_index_mapping
end
