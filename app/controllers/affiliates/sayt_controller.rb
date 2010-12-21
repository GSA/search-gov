class Affiliates::SaytController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate

  def index
    @sayt_suggestion = SaytSuggestion.new
    @sayt_suggestions = SaytSuggestion.paginate_by_affiliate_id(@affiliate.id, :page => params[:page] || 1, :order => 'phrase ASC')
  end
  
  def create
    @sayt_suggestion = SaytSuggestion.new(params[:sayt_suggestion])
    @sayt_suggestion.affiliate = @affiliate
    if @sayt_suggestion.save
      flash[:success] = "Successfully added: #{@sayt_suggestion.phrase}"
    else
      flash[:error] = "Unable to add: <b>#{@sayt_suggestion.phrase}</b>; Please check the phrase and try again.  Note: <ul><li>Duplicate phrases are rejected.</li><li>Phrases must be at least 3 characters.</li></ul>"
    end
    redirect_to affiliate_type_ahead_search_index_path(@affiliate)
  end
  
  def destroy
    @sayt_suggestion = SaytSuggestion.find(params[:id])
    if @sayt_suggestion
      @sayt_suggestion.destroy
      flash[:success] = "Deleted phrase: #{@sayt_suggestion.phrase}"
    end
    redirect_to affiliate_type_ahead_search_index_path(@affiliate)
  end
  
  def upload
    result = SaytSuggestion.process_sayt_suggestion_txt_upload(params[:txtfile], @affiliate)
    if result
      flashy = "#{result[:created]} Type-ahead Search suggestions uploaded successfully."
      flashy += " #{result[:ignored]} Type-ahead Search suggestions ignored." if result[:ignored] > 0
      flash[:success] = flashy
    else
      flash[:error] = "Your file could not be processed. Please check the format and try again."
    end
    redirect_to affiliate_type_ahead_search_index_path(@affiliate)
  end
  
  def preferences
    if params[:sayt_preferences] == 'enable_affiliate'
      @affiliate.update_attributes(:is_sayt_enabled => true, :is_affiliate_suggestions_enabled => true)
    elsif params[:sayt_preferences] == 'enable_global'
      @affiliate.update_attributes(:is_sayt_enabled => true, :is_affiliate_suggestions_enabled => false)
    elsif params[:sayt_preferences] == 'disable'
      @affiliate.update_attributes(:is_sayt_enabled => false, :is_affiliate_suggestions_enabled => false)
    end
    flash[:success] = 'Preferences updated.'
    redirect_to affiliate_type_ahead_search_index_path(@affiliate)    
  end
end