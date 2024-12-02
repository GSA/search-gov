# frozen_string_literal: true

module Admin
  class BulkZombieUrlUploadController < AdminController
    def index
      @page_title = 'Bulk Zombie Url Upload'
    end

    def upload
      begin
        @file = params[:bulk_upload_zombie_urls]
        BulkZombieUrls::FileValidator.new(@file).validate!
        enqueue_job
        flash[:success] = success_message(@file.original_filename)
      rescue BulkZombieUrlUploader::Error => e
        Rails.logger.error 'Zombie Url upload failed', e
        flash[:error] = e.message
      end

      redirect_to admin_bulk_zombie_url_upload_index_path
    end

    private

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
end
