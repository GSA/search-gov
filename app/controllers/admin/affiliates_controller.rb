class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.columns = [:name, :domains, :header, :footer, :affiliate_template, :boosted_sites, :is_sayt_enabled, :is_affiliate_suggestions_enabled, :created_at, :updated_at]
    config.list.sorting = { :name => :asc }
    config.update.columns = [:name, :domains, :header, :footer, :affiliate_template, :is_sayt_enabled, :is_affiliate_suggestions_enabled]
    config.create.columns = [:name, :domains, :header, :footer, :affiliate_template]
    config.columns[:is_sayt_enabled].label = "Enable SAYT"
    config.columns[:is_affiliate_suggestions_enabled].label = "Enable Affiliate SAYT Suggestions"
    config.action_links.add "analytics", :label => "Analytics", :type => :member, :page => true
  end
  
  def analytics
    redirect_to affiliate_analytics_home_page_path(:id => params[:id])
  end

end
