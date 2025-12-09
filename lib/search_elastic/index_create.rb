# frozen_string_literal: true

module SearchElastic
  class IndexCreate
    def initialize(service_name:, index_name:, shards:, replicas:)
      @client = nil
      @service_name = service_name.upcase
      raise ArgumentError, \
        "service_name must be 'ELASTICSEARCH' or 'OPENSEARCH'" \
        unless %w[ELASTICSEARCH OPENSEARCH].include?(@service_name)

      @index_name = index_name
      @shards = shards
      @replicas = replicas
    end

    def create_or_update_index(client)
      @client = client
      index_pattern = "*#{@index_name}*"
      template_generator = SearchElastic::Template.new(index_pattern, @shards, @replicas)
      # We need to do this because the template generator returns a string.
      # Also, some times we only need a subset of the template (e.g: mappings, settings, but not index_patterns).
      template_body = JSON.parse(template_generator.body)

      # Can't use `put_index_template` because of the
      # elasticsearch-ruby (and elasticsearch) version we're using
      @client.indices.put_template(
        name: @index_name,
        body: template_body
      )

      if @client.indices.exists?(index: @index_name)
        Rails.logger.info { "Index #{@index_name} already exists in #{@service_name}. Updating mapping..." }
        update_index_mapping(@index_name, template_body)
      else
        Rails.logger.info { "Creating new #{@service_name} index: #{@index_name}" }
        @client.indices.create(
          index: @index_name,
          body: {
            settings: template_body['settings'],
            mappings: template_body['mappings']
          }
        )
      end
    end

    private

    def update_index_mapping(index_name, template_body)
      # Only send mappings in the put_mapping call. Settings (including replicas)
      # are updated separately via put_settings because put_mapping does not
      # accept settings and some settings (like number_of_shards) are immutable.
      @client.indices.put_mapping(
        index: index_name,
        body: template_body['mappings'] || {}
      )

      Rails.logger.info { "Successfully updated #{@service_name} mapping for index: #{index_name}" }

      begin
        # Only extract and apply dynamic settings that can be updated
        @client.indices.put_settings(
          index: index_name,
          body: {
            index: {
              "number_of_replicas" => @replicas
            }
          }
        )

        Rails.logger.info { "Updated #{@service_name} index settings (number_of_replicas) for index: #{index_name}" }
      rescue => e
        # Log and continue; failing to update a dynamic setting should not abort mapping updates.
        Rails.logger.warn { "Failed to update #{@service_name} index settings for #{index_name}: #{e.message}" }
      end

    rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
      # Common reasons include attempting to change an existing field type — handle gracefully.
      if e.message =~ /mapper_parsing_exception|illegal_argument_exception/
        Rails.logger.warn { "Cannot update #{@service_name} mapping for #{index_name}: #{e.message}" }
      else
        raise
      end
    end
  end
end
