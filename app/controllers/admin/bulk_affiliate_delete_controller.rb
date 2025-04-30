class Admin::BulkAffiliateDeleteController < Admin::AdminController
  def index
    @page_title = 'Bulk Affiliate Delete'
  end

  def upload
    @file = params[:file]

    unless @file
      flash[:error] = t('flash_messages.admin.bulk_affiliate_delete.upload.no_file_selected')
      return redirect_to admin_bulk_affiliate_delete_index_path
    end

    BulkAffiliateDeleteJob.perform_later(
      current_user.email,
      @file.original_filename,
      @file.tempfile.path
    )
    flash[:notice] = success_message(@file.original_filename)

    redirect_to admin_bulk_affiliate_delete_index_path
  end

  private

  def success_message(filename)
    <<~SUCCESS_MESSAGE
      Successfully uploaded #{filename} for processing.
      The deletion results will be emailed to you.
    SUCCESS_MESSAGE
  end
end
