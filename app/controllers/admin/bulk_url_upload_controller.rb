# frozen_string_literal: true

module Admin
  class BulkUrlUploadController < AdminController
    def index
      @page_title = 'Bulk URL Upload'
    end

    def upload
      begin
        file= params[:bulk_upload_urls]
        raise(BulkUrlUploader::Error, 'Please choose a file to upload.') if file.blank?

        BulkUrlUploadJobCreator.new(file, current_user).create_job!
        flash[:success]= "Successfully uploaded #{file.original_filename} for processing."
      rescue BulkUrlUploader::Error => e
        flash[:error]= e.message
      end

      redirect_to admin_bulk_url_upload_index_path
    end
  end
end
