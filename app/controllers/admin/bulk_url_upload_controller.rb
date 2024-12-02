# frozen_string_literal: true

module Admin
  class BulkUrlUploadController < AdminController
    include BulkUploadHandler
    before_action :set_page_title

    def index; end

    def upload
      handle_bulk_upload(
        params_key: :bulk_upload_urls,
        validator_class: BulkUrlUploader::UrlFileValidator,
        error_class: BulkUrlUploader::Error,
        success_path: admin_bulk_url_upload_index_path,
        logger_message: 'Url upload failed'
      )
    end

    private

    def set_page_title
      @page_title = 'Bulk URL Upload'
    end

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
