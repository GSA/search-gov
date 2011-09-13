class Affiliates::PopularLinksController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  
  def index
  end
  
  def preferences
    @affiliate.is_popular_links_enabled = (params["is_popular_links_enabled"] == "true" ? true : false)
    @affiliate.save
    flash[:success] = @affiliate.is_popular_links_enabled ? "Popular Links ENABLED." : "Popular Links DISABLED."
    redirect_to affiliate_popular_links_path(@affiliate)
  end
end