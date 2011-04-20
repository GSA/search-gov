class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.columns = [:display_name, :name, :domains, :header, :footer, :affiliate_template, :boosted_contents, :is_sayt_enabled, :is_affiliate_suggestions_enabled, :created_at, :updated_at]
    config.list.sorting = { :display_name => :asc }
    config.update.columns = [:display_name, :domains, :staged_domains, :search_results_page_title, :staged_search_results_page_title, :header, :staged_header, :footer, :staged_footer, :affiliate_template, :staged_affiliate_template, :is_sayt_enabled, :is_affiliate_suggestions_enabled, :has_staged_content]
    config.create.columns = [:display_name, :name, :domains, :header, :footer, :affiliate_template]
    config.columns[:staged_search_results_page_title].label = "Staged search results page title"
    config.columns[:is_sayt_enabled].label = "Enable SAYT"
    config.columns[:is_affiliate_suggestions_enabled].label = "Enable Affiliate SAYT Suggestions"
    config.columns[:affiliate_template].form_ui= :select
    config.columns[:staged_affiliate_template].form_ui= :select
    config.action_links.add "analytics", :label => "Analytics", :type => :member, :page => true
  end

  def analytics
    redirect_to affiliate_analytics_path(:affiliate_id => params[:id])
  end

end
