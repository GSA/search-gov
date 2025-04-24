class BulkAffiliateDeleteJob < ApplicationJob
  queue_as :searchgov

  def perform(requesting_user_email, file_name, file_path)
    unless File.exist?(file_path)
      logger.error "BulkAffiliateDeleteJob: File not found - #{file_path} for user #{requesting_user_email}"
      return
    end

    uploader = BulkAffiliateDeleteUploader.new(file_name, file_path, requesting_user_email)
    results = uploader.parse_file

    if results.errors? || results.valid_affiliate_ids.empty?
      Rails.logger.warn <<~WARN.squish
        BulkAffiliateDeleteJob: Parsing failed or no valid IDs found for #{file_name}.
        User: #{requesting_user_email}.
        Summary: #{results.summary_message}.
        General Errors: #{results.general_errors.join('; ')}.
        Row Errors: #{results.error_details.count}.
      WARN

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
          logger.error "BulkAffiliateDeleteJob: Failed to delete Affiliate #{id_text}: #{e.message}"
        end
      else
        failed_deletions << [id_text, "Not Found"]
        logger.warn "BulkAffiliateDeleteJob: Affiliate #{id_text} not found for deletion."
      end
    end

    BulkAffiliateDeleteMailer.notify(
      requesting_user_email,
      file_name,
      deleted_ids,
      failed_deletions
    ).deliver_now

  ensure
    FileUtils.rm_f(file_path) if file_path && File.exist?(file_path)
  end
end
