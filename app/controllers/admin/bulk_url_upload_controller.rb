# frozen_string_literal: true

module Admin
  class BulkUrlUploadController < AdminController
    def index
      @page_title = 'Bulk URL Upload'
    end

    def upload
      begin
        @file = params[:bulk_upload_urls]
        BulkUrlUploader::UrlFileValidator.new(@file).validate!
        enqueue_job
        flash[:success] = success_message(@file.original_filename)
      rescue BulkUrlUploader::Error => e
        flash[:error] = e.message
      end

      redirect_to admin_bulk_url_upload_index_path
    end

    private

    def success_message(filename)
      <<~SUCCESS_MESSAGE
        Successfully uploaded #{filename} for processing.
        The results will be emailed to you.
      SUCCESS_MESSAGE
    end

    def enqueue_job
      SearchgovUrlBulkUploaderJob.perform_later(
        current_user,
        @file.original_filename,
        @file.tempfile.set_encoding('UTF-8').readlines,
        reindex: ActiveModel::Type::Boolean.new.cast(params[:reindex])
      )
    end
  end
end
