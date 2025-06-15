class BulkAffiliateAddJob < ApplicationJob
  queue_as :searchgov

  def perform(requesting_user_email, file_name, s3_object_key, email_address)
    temp_file = download_from_s3(s3_object_key)

    uploader = BulkAffiliateAddUploader.new(file_name, temp_file.path, email_address)
    results = uploader.parse_file

    if results.errors? || results.valid_affiliate_ids.empty?
      Rails.logger.warn <<~WARN.squish
        BulkAffiliateAddJob: Parsing failed or no valid IDs found for #{file_name}.
        User: #{requesting_user_email}.
        Summary: #{results.summary_message}.
        General Errors: #{results.general_errors.join('; ')}.
        Row Errors: #{results.error_details.count}.
      WARN

      BulkAffiliateAddMailer.notify_parsing_failure(
        requesting_user_email,
        file_name,
        results.general_errors,
        results.error_details
      ).deliver_later
    end

    added_sites = []
    failed_additions = []
    affiliate_ids_to_process = results.valid_affiliate_ids

    user = User.find_by_email(email_address)
    if user.nil?
      error_message = "User with email '#{email_address}' not found. No affiliates were processed."
      Rails.logger.error "BulkAffiliateAddJob: #{error_message}"
      BulkAffiliateAddMailer.notify_parsing_failure(
        requesting_user_email,
        file_name,
        [error_message],
        []
      ).deliver_later
    else
      affiliate_ids_to_process.each do |affiliate_name|
        affiliate = Affiliate.find_by_name(affiliate_name)
        if affiliate
          if affiliate.users.exists?(id: user.id)
            failed_additions << [affiliate_name, "User already a member."]
          else
            begin
              user.add_to_affiliate(affiliate, 'Bulk upload script')
              added_sites << affiliate_name
            rescue StandardError => e
              failed_additions << [affiliate_name, e.message]
              logger.error "BulkAffiliateAddJob: Failed to add user to Affiliate #{affiliate_name}: #{e.message}"
            end
          end
        else
          failed_additions << [affiliate_name, "Not Found"]
          Rails.logger.warn "BulkAffiliateAddJob: Affiliate #{affiliate_name} not found."
        end
      end

      BulkAffiliateAddMailer.notify(
        requesting_user_email,
        file_name,
        added_sites,
        failed_additions
      ).deliver_later
    end

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
    temp_file = Tempfile.new(%w[bulk_add_user.csv])
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