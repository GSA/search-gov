class Admin::BulkAffiliateAddController < Admin::AdminController
  include BulkOperationS3Uploadable

  def index
    @page_title = 'Bulk Add User to Affiliates'
  end

  def upload
    uploaded_file = params[:file]
    user_email = params[:email]

    unless uploaded_file && user_email.present?
      flash[:error] = t('flash_messages.admin.bulk_upload.missing_data', action: 'add')
      return redirect_to admin_bulk_affiliate_add_index_path
    end

    s3_object_key = upload_to_s3(uploaded_file)
    BulkAffiliateAddJob.perform_later(
      current_user.email,
      uploaded_file.original_filename,
      s3_object_key,
      user_email
    )

    flash[:notice] = success_message(uploaded_file.original_filename)
    redirect_to admin_bulk_affiliate_add_index_path
  end

  private

  def s3_object_key_prefix
    "bulk-add-user-uploads"
  end

  def bulk_action_description
    "user affiliate additions"
  end
end