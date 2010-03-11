class Admin::SaytSuggestionsUploadsController < Admin::AdminController
  def new
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
      render :action => 'new'
    end
  end

end
