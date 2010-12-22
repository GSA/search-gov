class Affiliates::RelatedTopicsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  
  def index
  end
  
  def preferences
    related_topics_setting = params[:related_topics_setting]
    if Affiliate::VALID_RELATED_TOPICS_SETTINGS.include? related_topics_setting
      @affiliate.update_attributes(:related_topics_setting => related_topics_setting)
      flash[:success] = "Preferences updated."
    end
    redirect_to affiliate_related_topics_path(@affiliate)
  end
end