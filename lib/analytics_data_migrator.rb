# frozen_string_literal: true

require 'elasticsearch'

class AnalyticsDataMigrator
  SCROLL_SIZE = 1000
  SCROLL_TIMEOUT = '5m'
  INDEX_PREFIXES = %w[logstash human-logstash].freeze

  attr_reader :start_date, :end_date, :dry_run, :logger

  def initialize(start_date:, end_date:, dry_run: false, logger: Rails.logger)
    @start_date = start_date
    @end_date = end_date
    @dry_run = dry_run
    @logger = logger
  end

  def migrate
    log_info("Starting analytics data migration from #{start_date} to #{end_date}")
    log_info("DRY RUN MODE - no data will be written") if dry_run

    validate_clients!

    total_migrated = 0
    total_errors = 0

    each_date do |date|
      INDEX_PREFIXES.each do |prefix|
        index_name = "#{prefix}-#{date.strftime('%Y.%m.%d')}"
        result = migrate_index(index_name)
        total_migrated += result[:migrated]
        total_errors += result[:errors]
      end
    end

    log_info("Migration complete. Total documents migrated: #{total_migrated}, errors: #{total_errors}")
    { migrated: total_migrated, errors: total_errors }
  end

  def migrate_index(index_name)
    unless source_index_exists?(index_name)
      log_info("Source index #{index_name} does not exist, skipping")
      return { migrated: 0, errors: 0 }
    end

    ensure_destination_index(index_name)

    log_info("Migrating index: #{index_name}")

    migrated = 0
    errors = 0
    scroll_id = nil

    begin
      response = source_client.search(
        index: index_name,
        scroll: SCROLL_TIMEOUT,
        size: SCROLL_SIZE,
        body: { query: { match_all: {} } }
      )

      scroll_id = response['_scroll_id']
      hits = response.dig('hits', 'hits') || []

      while hits.any?
        result = process_batch(index_name, hits)
        migrated += result[:success]
        errors += result[:errors]

        response = source_client.scroll(scroll_id: scroll_id, scroll: SCROLL_TIMEOUT)
        scroll_id = response['_scroll_id']
        hits = response.dig('hits', 'hits') || []
      end
    rescue StandardError => e
      log_error("Error migrating index #{index_name}: #{e.message}")
      errors += 1
    ensure
      clear_scroll(scroll_id) if scroll_id
    end

    log_info("Index #{index_name}: migrated #{migrated} documents, #{errors} errors")
    { migrated: migrated, errors: errors }
  end

  private

  def source_client
    @source_client ||= begin
      config = Rails.application.config_for(:elasticsearch_client).deep_symbolize_keys
      Elasticsearch::Client.new(config)
    end
  end

  def destination_client
    @destination_client ||= begin
      config = Rails.application.config_for(:opensearch_analytics_client).deep_symbolize_keys
      Elasticsearch::Client.new(config)
    end
  end

  def validate_clients!
    source_client.ping
    log_info("Connected to source ElasticSearch")
  rescue StandardError => e
    raise "Cannot connect to source ElasticSearch: #{e.message}"
  end

  def source_index_exists?(index_name)
    source_client.indices.exists?(index: index_name)
  end

  def ensure_destination_index(index_name)
    return if dry_run
    return if destination_client.indices.exists?(index: index_name)

    mappings = source_client.indices.get_mapping(index: index_name)
    settings = source_client.indices.get_settings(index: index_name)

    index_settings = settings.dig(index_name, 'settings', 'index') || {}
    filtered_settings = index_settings.except(
      'creation_date', 'uuid', 'version', 'provided_name',
      'number_of_replicas', 'number_of_shards'
    )

    body = {
      settings: filtered_settings.merge(
        'number_of_shards' => index_settings['number_of_shards'] || 1,
        'number_of_replicas' => index_settings['number_of_replicas'] || 1
      ),
      mappings: mappings.dig(index_name, 'mappings') || {}
    }

    destination_client.indices.create(index: index_name, body: body)
    log_info("Created destination index: #{index_name}")
  rescue StandardError => e
    log_error("Failed to create destination index #{index_name}: #{e.message}")
  end

  def process_batch(index_name, hits)
    return { success: hits.size, errors: 0 } if dry_run

    bulk_body = hits.flat_map do |hit|
      [
        { index: { _index: index_name, _id: hit['_id'] } },
        hit['_source']
      ]
    end

    response = destination_client.bulk(body: bulk_body)

    if response['errors']
      error_count = response['items'].count { |item| item.dig('index', 'error') }
      { success: hits.size - error_count, errors: error_count }
    else
      { success: hits.size, errors: 0 }
    end
  rescue StandardError => e
    log_error("Bulk insert error: #{e.message}")
    { success: 0, errors: hits.size }
  end

  def clear_scroll(scroll_id)
    source_client.clear_scroll(scroll_id: scroll_id)
  rescue StandardError
    # Ignore scroll cleanup errors
  end

  def each_date(&)
    (start_date..end_date).each(&)
  end

  def log_info(message)
    logger.info("[AnalyticsDataMigrator] #{message}")
    puts message if defined?(Rake)
  end

  def log_error(message)
    logger.error("[AnalyticsDataMigrator] #{message}")
    puts "ERROR: #{message}" if defined?(Rake)
  end
end
