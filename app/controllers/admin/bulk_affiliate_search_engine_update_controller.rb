# frozen_string_literal: true

class Admin::BulkAffiliateSearchEngineUpdateController < Admin::AdminController
  include BulkOperationS3Uploadable

  def index
    @page_title = 'Bulk Affiliate Search Engine Update'
  end

  def upload
    uploaded_file = params[:file]

    unless uploaded_file
      flash[:error] = t('flash_messages.admin.bulk_upload.no_file_selected', action: 'search engine update')
      return redirect_to admin_bulk_affiliate_search_engine_update_index_path
    end

    s3_object_key = upload_to_s3(uploaded_file)

    BulkAffiliateSearchEngineUpdateJob.perform_later(
      current_user.email,
      uploaded_file.original_filename,
      s3_object_key
    )

    flash[:notice] = success_message(uploaded_file.original_filename)

    redirect_to admin_bulk_affiliate_search_engine_update_index_path
  end

  private

  def s3_object_key_prefix
    "bulk-search-engine-update-uploads"
  end

  def bulk_action_description
    "search engine update"
  end
end