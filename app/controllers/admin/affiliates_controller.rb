class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.columns = [:display_name, :name, :site_domains, :affiliate_template, :boosted_contents, :is_sayt_enabled, :created_at, :updated_at]
    config.list.sorting = { :display_name => :asc }
    config.columns << [:header_footer_css, :staged_header_footer_css, :header, :staged_header, :footer, :staged_footer]
    config.columns[:header_footer_css].form_ui = :textarea
    config.columns[:staged_header_footer_css].form_ui = :textarea
    config.columns[:header].form_ui = :textarea
    config.columns[:staged_header].form_ui = :textarea
    config.columns[:footer].form_ui = :textarea
    config.columns[:staged_footer].form_ui = :textarea
    config.update.columns = [:display_name, :search_results_page_title, :staged_search_results_page_title,
                             :facebook_handle, :flickr_url, :twitter_handle, :youtube_handle,
                             :uses_one_serp, :theme, :staged_theme,
                             :header_footer_css, :staged_header_footer_css,
                             :header, :staged_header, :footer, :staged_footer,
                             :favicon_url, :staged_favicon_url, :external_css_url, :staged_external_css_url,
                             :affiliate_template, :staged_affiliate_template, :is_sayt_enabled, :has_staged_content, :exclude_webtrends, :popular_urls, :locale, :results_source, :sitemaps]
    config.list.columns.exclude [:header_footer_css, :staged_header_footer_css, :header, :staged_header, :footer, :staged_footer]
    config.create.columns = [:display_name, :name, :search_results_page_title, :header_footer_css, :header, :footer, :affiliate_template, :locale]
    config.columns[:staged_search_results_page_title].label = "Staged search results page title"
    config.columns[:is_sayt_enabled].label = "Enable SAYT"
    config.columns[:affiliate_template].form_ui= :select
    config.columns[:staged_affiliate_template].form_ui= :select
    config.columns[:theme].form_ui = :select
    config.columns[:staged_theme].form_ui = :select
    theme_options = Affiliate::THEMES.keys.collect { |key| [Affiliate::THEMES[key][:display_name], key.to_s] }
    config.columns[:theme].options = { :include_blank => '', :options => theme_options }
    config.columns[:staged_theme].options = { :include_blank => '', :options => theme_options }
    config.columns[:results_source].form_ui = :select
    config.columns[:results_source].options = { :include_blank => false, :options => Affiliate::RESULTS_SOURCES }
    config.action_links.add "analytics", :label => "Analytics", :type => :member, :page => true
    actions.add :export
  end

  def analytics
    redirect_to affiliate_analytics_path(:affiliate_id => params[:id])
  end
end