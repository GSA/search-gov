# frozen_string_literal: true

require_relative '../analytics_data_migrator'

namespace :opensearch do
  namespace :analytics do
    desc 'Migrate analytics data from ElasticSearch to OpenSearch'
    task :migrate, [:start_date, :end_date] => :environment do |_t, args|
      start_date = parse_date(args.start_date, 18.months.ago.to_date)
      end_date = parse_date(args.end_date, Date.today)

      puts "Migrating analytics data from #{start_date} to #{end_date}"
      puts "This will migrate logstash-* indices (human-logstash-* are aliases created by OpenSearch templates)"
      puts "Tip: Set VERBOSE=true for detailed HTTP logging"
      puts ""

      migrator = AnalyticsDataMigrator.new(
        start_date: start_date,
        end_date: end_date,
        verbose: ENV['VERBOSE'] == 'true'
      )

      result = migrator.migrate
      puts ""
      puts "Migration complete!"
      puts "Documents migrated: #{result[:migrated]}"
      puts "Errors: #{result[:errors]}"
    end

    desc 'Dry run: show what would be migrated without making changes'
    task :migrate_dry_run, [:start_date, :end_date] => :environment do |_t, args|
      start_date = parse_date(args.start_date, 18.months.ago.to_date)
      end_date = parse_date(args.end_date, Date.today)

      puts "[DRY RUN] Simulating migration from #{start_date} to #{end_date}"
      puts "No data will be written to OpenSearch"
      puts "Tip: Set VERBOSE=true for detailed HTTP logging"
      puts ""

      migrator = AnalyticsDataMigrator.new(
        start_date: start_date,
        end_date: end_date,
        dry_run: true,
        verbose: ENV['VERBOSE'] == 'true'
      )

      result = migrator.migrate
      puts ""
      puts "Dry run complete!"
      puts "Documents that would be migrated: #{result[:migrated]}"
    end

    desc 'Migrate a single index from ElasticSearch to OpenSearch'
    task :migrate_index, [:index_name] => :environment do |_t, args|
      unless args.index_name
        puts "Usage: rake opensearch:analytics:migrate_index[index_name]"
        puts "Example: rake opensearch:analytics:migrate_index[logstash-2024.01.15]"
        exit 1
      end

      puts "Migrating single index: #{args.index_name}"
      puts "Tip: Set VERBOSE=true for detailed HTTP logging"
      puts ""

      migrator = AnalyticsDataMigrator.new(
        start_date: Date.today,
        end_date: Date.today,
        verbose: ENV['VERBOSE'] == 'true'
      )

      result = migrator.migrate_index(args.index_name)
      puts ""
      puts "Migration complete!"
      puts "Documents migrated: #{result[:migrated]}"
      puts "Errors: #{result[:errors]}"
    end

    desc 'Check migration status - compare document counts between ES and OpenSearch'
    task :status, [:start_date, :end_date] => :environment do |_t, args|
      start_date = parse_date(args.start_date, 18.months.ago.to_date)
      end_date = parse_date(args.end_date, Date.today)

      puts "Checking migration status from #{start_date} to #{end_date}"
      puts ""

      es_config = Rails.application.config_for(:elasticsearch_client).deep_symbolize_keys.merge(log: false)
      os_config = Rails.application.config_for(:opensearch_analytics_client).deep_symbolize_keys.merge(log: false)

      es_client = Elasticsearch::Client.new(es_config)
      os_client = Elasticsearch::Client.new(os_config)

      total_es = 0
      total_os = 0
      missing_indices = []

      (start_date..end_date).each do |date|
        index_name = "logstash-#{date.strftime('%Y.%m.%d')}"

        es_count = get_doc_count(es_client, index_name)
        os_count = get_doc_count(os_client, index_name)

        total_es += es_count
        total_os += os_count

        if es_count > 0 && os_count == 0
          missing_indices << index_name
        elsif es_count != os_count && es_count > 0
          puts "#{index_name}: ES=#{es_count}, OS=#{os_count} (diff: #{es_count - os_count})"
        end
      end

      puts ""
      puts "Summary:"
      puts "  Total documents in ElasticSearch: #{total_es}"
      puts "  Total documents in OpenSearch: #{total_os}"
      puts "  Migration progress: #{total_os.to_f / total_es * 100}%" if total_es > 0
      puts ""

      if missing_indices.any?
        puts "Missing indices in OpenSearch (#{missing_indices.size}):"
        missing_indices.first(10).each { |idx| puts "  - #{idx}" }
        puts "  ... and #{missing_indices.size - 10} more" if missing_indices.size > 10
      else
        puts "All indices have been migrated!"
      end
    end

    def parse_date(date_str, default)
      date_str.present? ? Date.parse(date_str) : default
    end

    def get_doc_count(client, index_name)
      return 0 unless client.indices.exists?(index: index_name)

      response = client.count(index: index_name)
      response['count']
    rescue StandardError
      0
    end
  end
end
