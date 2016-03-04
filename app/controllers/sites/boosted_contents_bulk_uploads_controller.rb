class Sites::BoostedContentsBulkUploadsController < Sites::SetupSiteController
  include ActionView::Helpers::TextHelper

  def new
  end

  def create
    uploader = BoostedContentBulkUploader.new(@site, bulk_upload_file)
    results = uploader.upload
    if results[:success]
      messages = []
      messages << 'Bulk upload is complete.'
      messages << "You have added #{pluralize(results[:created], 'Best Bets: Text')}."
      messages << "You have updated #{pluralize(results[:updated], 'Best Bets: Text')}." if results[:updated] > 0
      redirect_to site_best_bets_texts_path(@site),
                  flash: { success: "#{messages.join('<br/>')}".html_safe }
    else
      flash.now[:error] = results[:error_message]
      render action: :new
    end
  end

  private

  def bulk_upload_file
    params.permit(:best_bets_text_data_file)[:best_bets_text_data_file]
  end
end
