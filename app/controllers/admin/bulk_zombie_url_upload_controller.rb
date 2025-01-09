# frozen_string_literal: true

class Admin::BulkZombieUrlUploadController < Admin::BulkUploadController
  include BulkUploadHandler
  before_action :set_page_title

  def upload
    handle_bulk_upload(
      params_key: :bulk_upload_zombie_urls,
      validator_class: BulkZombieUrls::FileValidator,
      error_class: BulkZombieUrlUploader::Error,
      success_path: admin_bulk_zombie_url_upload_index_path,
      logger_message: 'Zombie Url upload failed'
    )
  end

  private

  def set_page_title
    @page_title = 'Bulk Zombie Url Upload'
  end

  def success_message(filename)
    <<~SUCCESS_MESSAGE
      Successfully uploaded #{filename} for processing.
      The results will be emailed to you.
    SUCCESS_MESSAGE
  end

  def enqueue_job
    s3_client = Aws::S3::Client.new(region: ENV['AWS_REGION'])
    filepath = "#{Rails.env}/file_uploads/#{SecureRandom.uuid}/#{@file.original_filename}"

    s3_client.put_object(
      bucket: ENV['AWS_BUCKET'],
      key: filepath,
      body: @file.tempfile.set_encoding('UTF-8')
    )

    BulkZombieUrlUploaderJob.perform_now(
      current_user,
      @file.original_filename,
      filepath,
    )
  end
end
