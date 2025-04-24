require 'spec_helper'
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

    begin
      BulkAffiliateDeleteJob.perform_later(
        current_user.email,
        @file.original_filename,
        @file.tempfile.path
      )
      flash[:notice] = success_message(@file.original_filename)
    rescue StandardError => e
      logger.error "Failed to enqueue BulkAffiliateDeleteJob: #{e.message}"
      flash[:error] = flash[:error] = t('flash_messages.admin.bulk_affiliate_delete.upload.queue_error')

    end

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
