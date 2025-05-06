class BulkAffiliateDeleteJob < ApplicationJob
  queue_as :searchgov

  def perform(requesting_user_email, file_name, s3_object_key)
    temp_file = download_from_s3(s3_object_key)

    uploader = BulkAffiliateDeleteUploader.new(file_name, temp_file.path)
    results = uploader.parse_file

    if results.errors? || results.valid_affiliate_ids.empty?
      Rails.logger.warn <<~WARN.squish
        BulkAffiliateDeleteJob: Parsing failed or no valid IDs found for #{file_name}.
        User: #{requesting_user_email}.
        Summary: #{results.summary_message}.
        General Errors: #{results.general_errors.join('; ')}.
        Row Errors: #{results.error_details.count}.
      WARN

      BulkAffiliateDeleteMailer.notify_parsing_failure(
        requesting_user_email,
        file_name,
        results.general_errors,
        results.error_details
      ).deliver_now!

      return
    end

    deleted_ids = []
    failed_deletions = []
    affiliate_ids_to_process = results.valid_affiliate_ids

    affiliate_ids_to_process.each do |id_text|
      id = id_text.to_i
      affiliate = Affiliate.find_by(id: id)
      if affiliate
        begin
          affiliate.destroy!
          deleted_ids << id_text
        rescue StandardError => e
          failed_deletions << [id_text, e.message]
          Rails.logger.error "BulkAffiliateDeleteJob: Failed to delete Affiliate #{id_text}: #{e.message}"
        end
      else
        failed_deletions << [id_text, "Not Found"]
        Rails.logger.warn "BulkAffiliateDeleteJob: Affiliate #{id_text} not found for deletion."
      end
    end

    BulkAffiliateDeleteMailer.notify(
      requesting_user_email,
      file_name,
      deleted_ids,
      failed_deletions
    ).deliver_now!

  ensure
    FileUtils.rm_f(file_path) if file_path && File.exist?(file_path)
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
    temp_file = Tempfile.new(%w[bulk_delete_download.csv])
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
end
