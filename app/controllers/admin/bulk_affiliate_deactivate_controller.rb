# frozen_string_literal: true

class Admin::BulkAffiliateDeactivateController < Admin::AdminController
  def index
    @page_title = 'Bulk Affiliate Deactivate'
  end

  def upload
    uploaded_file = params[:file]

    unless uploaded_file
      flash[:error] = t('flash_messages.admin.bulk_upload.no_file_selected', action: 'deactivation')
      return redirect_to admin_bulk_affiliate_deactivate_index_path
    end

    s3_object_key = upload_to_s3(uploaded_file)

    BulkAffiliateDeactivateJob.perform_later(
      current_user.email,
      uploaded_file.original_filename,
      s3_object_key
    )

    flash[:notice] = success_message(uploaded_file.original_filename)

    redirect_to admin_bulk_affiliate_deactivate_index_path
  end

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region: S3_CREDENTIALS[:s3_region],
      access_key_id: S3_CREDENTIALS[:access_key_id],
      secret_access_key: S3_CREDENTIALS[:secret_access_key]
    )
  end

  def upload_to_s3(uploaded_file)
    s3_key = "bulk-deactivate-uploads/#{Time.now.to_i}-#{SecureRandom.hex(8)}-#{uploaded_file.original_filename}"

    s3_client.put_object(
      bucket: S3_CREDENTIALS[:bucket],
      key: s3_key,
      body: uploaded_file.tempfile
    )

    s3_key
  end

  def success_message(filename)
    <<~SUCCESS_MESSAGE
      Successfully uploaded #{helpers.sanitize(filename)} for processing.
      The affiliate deactivation results will be emailed to you.
    SUCCESS_MESSAGE
  end
end
