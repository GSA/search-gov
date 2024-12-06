# frozen_string_literal: true

class Admin::BulkZombieUrlUploadController < Admin::BulkUploadController
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
    BulkZombieUrlUploaderJob.perform_later(
      current_user,
      @file.original_filename,
      @file.tempfile.path
    )
  end
end
