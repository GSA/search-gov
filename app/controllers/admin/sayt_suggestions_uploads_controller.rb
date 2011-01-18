class Admin::SaytSuggestionsUploadsController < Admin::AdminController
  PAGE_TITLE = "SAYT Suggestions Bulk Upload"
  def new
    @page_title = PAGE_TITLE
  end

  def create
    result = SaytSuggestion.process_sayt_suggestion_txt_upload(params[:txtfile])
    if result
      flashy = "#{result[:created]} SAYT suggestions uploaded successfully."
      flashy += " #{result[:ignored]} SAYT suggestions ignored." if result[:ignored] > 0
      flash[:success] = flashy
      redirect_to admin_sayt_suggestions_path
    else
      flash[:error] = "Your file could not be processed. Please check the format and try again."
      @page_title = PAGE_TITLE
      render :action => :new
    end
  end
end
