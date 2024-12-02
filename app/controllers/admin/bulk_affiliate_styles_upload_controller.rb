# frozen_string_literal: true

module Admin
  class BulkAffiliateStylesUploadController < AdminController
    include BulkUploadHandler
    before_action :set_page_title

    def index; end

    def upload
      handle_bulk_upload(
        params_key: :bulk_upload_affiliate_styles,
        validator_class: BulkAffiliateStyles::FileValidator,
        error_class: BulkAffiliateStylesUploader::Error,
        success_path: admin_bulk_affiliate_styles_upload_index_path,
        logger_message: 'Bulk Affiliate Styles upload failed'
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
      BulkAffiliateStylesUploaderJob.perform_later(
        current_user,
        @file.original_filename,
        @file.tempfile.path
      )
    end
  end
end
