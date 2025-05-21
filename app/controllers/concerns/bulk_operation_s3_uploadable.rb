module BulkOperationS3Uploadable
  extend ActiveSupport::Concern

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region: S3_CREDENTIALS[:s3_region],
      access_key_id: S3_CREDENTIALS[:access_key_id],
      secret_access_key: S3_CREDENTIALS[:secret_access_key]
    )
  end

  def upload_to_s3(uploaded_file)
    s3_key_folder = s3_object_key_prefix
    s3_key = "#{s3_key_folder}/#{Time.now.to_i}-#{SecureRandom.hex(8)}-#{uploaded_file.original_filename}"

    s3_client.put_object(
      bucket: S3_CREDENTIALS[:bucket],
      key: s3_key,
      body: uploaded_file.tempfile
    )

    s3_key
  end

  def success_message(filename)
    action_results_text = bulk_action_description
    <<~SUCCESS_MESSAGE
      Successfully uploaded #{helpers.sanitize(filename)} for processing.
      The affiliate #{action_results_text} results will be emailed to you.
    SUCCESS_MESSAGE
  end
end