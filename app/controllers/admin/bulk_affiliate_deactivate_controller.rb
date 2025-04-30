# frozen_string_literal: true

class Admin::BulkAffiliateDeactivateController < Admin::AdminController
  def index
    @page_title = 'Bulk Affiliate Deactivate'
  end

  def upload
    @file = params[:file]

    unless @file
      flash[:error] = t('flash_messages.admin.bulk_upload.no_file_selected', action: 'deactivation')
      return redirect_to admin_bulk_affiliate_deactivate_index_path
    end

    BulkAffiliateDeactivateJob.perform_later(
      current_user.email,
      @file.original_filename,
      @file.tempfile.path
    )

    flash[:notice] = success_message(@file.original_filename)
    redirect_to admin_bulk_affiliate_deactivate_index_path
  end

  private

  def success_message(filename)
    <<~SUCCESS_MESSAGE
      Successfully uploaded #{helpers.sanitize(filename)} for processing.
      The affiliate deactivation results will be emailed to you.
    SUCCESS_MESSAGE
  end
end