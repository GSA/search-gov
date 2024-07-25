# frozen_string_literal: true

module Admin
  class BulkAffiliateStylesUploadController < AdminController
    def index
      @page_title = 'Bulk Affiliate Styles Upload'
    end

    def upload
      begin
        @file = params[:bulk_upload_affiliate_styles]
        BulkAffiliateStyles::FileValidator.new(@file).validate!
        enqueue_job
        flash[:success] = success_message(@file.original_filename)
      rescue BulkAffiliateStylesUploader::Error => e
        flash[:error] = e.message
      end

      redirect_to admin_bulk_affiliate_styles_upload_index_path
    end

    private

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
