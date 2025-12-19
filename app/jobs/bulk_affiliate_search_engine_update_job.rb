# frozen_string_literal: true

class BulkAffiliateSearchEngineUpdateJob < ApplicationJob
  queue_as :searchgov

  VALID_SEARCH_ENGINES = %w[bing_v7 search_gov search_elastic opensearch].freeze

  def perform(requesting_user_email, file_name, s3_object_key)
    temp_file = download_from_s3(s3_object_key)

    uploader = BulkAffiliateSearchEngineUpdateUploader.new(file_name, temp_file.path)
    results = uploader.parse_file

    if results.errors? || results.success_items.empty?
      log_parsing_failure(requesting_user_email, file_name, results)
      BulkAffiliateSearchEngineUpdateMailer.notify_parsing_failure(
        requesting_user_email,
        file_name,
        results.general_errors,
        results.error_details
      ).deliver_later

      return
    end

    process_affiliate_search_engine_updates(requesting_user_email, file_name, results.success_items)
  ensure
    FileUtils.rm_f(temp_file.path) if temp_file && File.exist?(temp_file.path)
  end

  private

  def s3_client
    Aws::S3::Client.new(
      region: S3_CREDENTIALS[:s3_region],
      access_key_id: S3_CREDENTIALS[:access_key_id],
      secret_access_key: S3_CREDENTIALS[:secret_access_key]
    )
  end

  def download_from_s3(s3_key)
    temp_file = Tempfile.new(%w[bulk_search_engine_update_download.csv])
    temp_file.binmode

    s3_client.get_object(
      bucket: S3_CREDENTIALS[:bucket],
      key: s3_key
    ) do |chunk|
      temp_file.write(chunk)
    end

    temp_file.rewind
    temp_file
  end

  def process_affiliate_search_engine_updates(requesting_user_email, file_name, valid_affiliate_data)
    successful_updates = []
    failed_updates = []

    valid_affiliate_data.each do |data|
      id = data[:id].to_i
      search_engine = data[:search_engine]
      affiliate = Affiliate.find_by(id: id)

      if affiliate
        begin
          if affiliate.update(search_engine: search_engine)
            successful_updates << { identifier: data[:id], search_engine: search_engine }
          else
            error_message = affiliate.errors.full_messages.join(', ')
            failed_updates << { identifier: data[:id], search_engine: search_engine, error: "Update failed: #{error_message}" }
            Rails.logger.error "BulkAffiliateSearchEngineUpdateJob: Failed to update Affiliate #{data[:id]} to #{search_engine}: #{error_message}"
          end
        rescue StandardError => e
          failed_updates << { identifier: data[:id], search_engine: search_engine, error: "Unexpected error: #{e.message}" }
          Rails.logger.error "BulkAffiliateSearchEngineUpdateJob: Unexpected error updating Affiliate #{data[:id]} to #{search_engine}: #{e.message}"
        end
      else
        failed_updates << { identifier: data[:id], search_engine: search_engine, error: 'Affiliate not found' }
        Rails.logger.warn "BulkAffiliateSearchEngineUpdateJob: Affiliate #{data[:id]} not found for search engine update."
      end
    end

    BulkAffiliateSearchEngineUpdateMailer.notify(
      requesting_user_email,
      file_name,
      successful_updates,
      failed_updates
    ).deliver_later
  end

  def log_parsing_failure(email, filename, results)
    Rails.logger.warn <<~WARN.squish
      BulkAffiliateSearchEngineUpdateJob: Parsing failed or no valid data found for #{filename}.
      User: #{email}.
      Summary: #{results.summary_message}.
      General Errors: #{results.general_errors.join('; ')}.
      Row Errors: #{results.error_details.count}.
    WARN
  end
end
