class Admin::BulkAffiliateDeleteController < Admin::AdminController
  PERSISTENT_UPLOAD_DIR = Rails.root.join('tmp', 'bulk_delete_uploads')

  def index
    @page_title = 'Bulk Affiliate Delete'
  end

  def upload
    uploaded_file = params[:file]

    unless uploaded_file
      flash[:error] = t('flash_messages.admin.bulk_affiliate_delete.upload.no_file_selected')
      return redirect_to admin_bulk_affiliate_delete_index_path
    end

    persistent_file_path = persist_uploaded_file(uploaded_file)

    BulkAffiliateDeleteJob.perform_later(
      current_user.email,
      uploaded_file.original_filename,
      persistent_file_path
    )

    flash[:notice] = success_message(uploaded_file.original_filename)
    redirect_to admin_bulk_affiliate_delete_index_path
  end

  private

  def persist_uploaded_file(uploaded_file)
    FileUtils.mkdir_p(PERSISTENT_UPLOAD_DIR)

    persistent_filename = "#{Time.now.to_i}-#{SecureRandom.hex(8)}-#{uploaded_file.original_filename}"
    persistent_file_path = PERSISTENT_UPLOAD_DIR.join(persistent_filename)

    FileUtils.cp(uploaded_file.tempfile.path, persistent_file_path)
    persistent_file_path.to_s
  end

  def success_message(filename)
    <<~SUCCESS_MESSAGE
      Successfully uploaded #{filename} for processing.
      The deletion results will be emailed to you.
    SUCCESS_MESSAGE
  end
end
