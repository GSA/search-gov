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
      messages << "You have added #{pluralize(results[:created], 'Text Best Bet')}."
      messages << "You have updated #{pluralize(results[:updated], 'Text Best Bet')}." if results[:updated] > 0
      messages << "#{pluralize(results[:failed], 'Text Best Bet')} #{was_or_were(results[:failed])} not uploaded. Please ensure the URLs are properly formatted, including the http:// or https:// prefix." if results[:failed] > 0
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

  def was_or_were(failures)
    failures > 1 ? 'were' : 'was'
  end
end
