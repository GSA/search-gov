class Admin::SuperfreshUrlsBulkUploadController < Admin::AdminController
  VALID_CONTENT_TYPES = %w{text/plain txt}

  def index
    @page_title = 'Superfresh Bulk Upload'
  end

  def upload
    file = params[:superfresh_urls]
    if file.present? and VALID_CONTENT_TYPES.include?(file.content_type)
      begin
        uploaded_count = SuperfreshUrl.process_file(file, nil, 65535)
        if uploaded_count > 0
          flash[:success] = "Successfully uploaded #{uploaded_count} urls."
        else
          flash[:error] = "No urls uploaded; please check your file and try again."
        end
      rescue StandardError => error
        flash[:error] = error.message
      end
    else
      flash[:error] = "Invalid file format; please upload a plain text file (.txt)."
    end
    redirect_to admin_superfresh_urls_bulk_upload_index_path
  end
end
