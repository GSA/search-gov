# frozen_string_literal: true

class BulkAffiliateDeactivateJob < ApplicationJob
  queue_as :searchgov

  def perform(requesting_user_email, file_name, s3_object_key)
    temp_file = download_from_s3(s3_object_key)

    uploader = BulkAffiliateDeactivateUploader.new(file_name, temp_file.path)
    results = uploader.parse_file

    if results.errors? || results.valid_affiliate_ids.empty?
      log_parsing_failure(requesting_user_email, file_name, results)
      BulkAffiliateDeactivateMailer.notify_parsing_failure(
        requesting_user_email,
        file_name,
        results.general_errors,
        results.error_details
      ).deliver_later

      return
    end

    process_affiliate_deactivations(requesting_user_email, file_name, results.valid_affiliate_ids)
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
    temp_file = Tempfile.new(%w[bulk_deactivate_download.csv])
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

  def process_affiliate_deactivations(requesting_user_email, file_name, valid_affiliate_ids)
    successful_deactivations = []
    failed_deactivations = []

    valid_affiliate_ids.each do |id_text|
      id = id_text.to_i
      affiliate = Affiliate.find_by(id: id)

      if affiliate
        begin
          if affiliate.update(active: false)
            successful_deactivations << id_text
          else
            error_message = affiliate.errors.full_messages.join(', ')
            failed_deactivations << { identifier: id_text, error: "Update failed: #{error_message}" }
            Rails.logger.error "BulkAffiliateDeactivateJob: Failed to deactivate Affiliate #{id_text}: #{error_message}"
          end
        rescue StandardError => e
          failed_deactivations << { identifier: id_text, error: "Unexpected error: #{e.message}" }
          Rails.logger.error "BulkAffiliateDeactivateJob: Unexpected error deactivating Affiliate #{id_text}: #{e.message}"
        end
      else
        failed_deactivations << { identifier: id_text, error: 'Affiliate not found' }
        Rails.logger.warn "BulkAffiliateDeactivateJob: Affiliate #{id_text} not found for deactivation."
      end
    end

    BulkAffiliateDeactivateMailer.notify(
      requesting_user_email,
      file_name,
      successful_deactivations,
      failed_deactivations
    ).deliver_later
  end

  def log_parsing_failure(email, filename, results)
    Rails.logger.warn <<~WARN.squish
          BulkAffiliateDeactivateJob: Parsing failed or no valid IDs found for #{filename}.
          User: #{email}.
          Summary: #{results.summary_message}.
          General Errors: #{results.general_errors.join('; ')}.
          Row Errors: #{results.error_details.count}.
        WARN
  end
end