class Admin::BulkAffiliateDeleteController < Admin::AdminController
  include BulkOperationS3Uploadable

  def index
    @page_title = 'Bulk Affiliate Delete'
  end

  def upload
    uploaded_file = params[:file]

    unless uploaded_file
      flash[:error] = t('flash_messages.admin.bulk_upload.no_file_selected', action: 'delete')
      return redirect_to admin_bulk_affiliate_delete_index_path
    end

    s3_object_key = upload_to_s3(uploaded_file)

    BulkAffiliateDeleteJob.perform_later(
      current_user.email,
      uploaded_file.original_filename,
      s3_object_key
    )

    flash[:notice] = success_message(uploaded_file.original_filename)

    redirect_to admin_bulk_affiliate_delete_index_path
  end

  private

  def s3_object_key_prefix
    "bulk-delete-uploads"
  end

  def bulk_action_description
    "deletion"
  end
end

