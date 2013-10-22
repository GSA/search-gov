class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.label = 'Sites'
    config.actions.exclude :delete
    config.columns = [:id, :display_name, :name, :site_domains, :affiliate_note, :created_at, :updated_at]
    config.columns[:affiliate_note].label = 'Note'
    config.list.sorting = { :display_name => :asc }
    virtual_columns = [:header_footer_css, :staged_header_footer_css, :header, :staged_header, :footer, :staged_footer,
                       :features, :external_tracking_code, :submitted_external_tracking_code]
    config.columns << virtual_columns
    config.columns[:header_footer_css].form_ui = :textarea
    config.columns[:staged_header_footer_css].form_ui = :textarea
    config.columns[:header].form_ui = :textarea
    config.columns[:staged_header].form_ui = :textarea
    config.columns[:footer].form_ui = :textarea
    config.columns[:staged_footer].form_ui = :textarea
    config.columns[:external_tracking_code].form_ui = :textarea
    config.columns[:submitted_external_tracking_code].form_ui = :textarea
    config.update.columns = [:display_name, :name,
                             :theme, :staged_theme,
                             :uses_managed_header_footer, :staged_uses_managed_header_footer,
                             :managed_header_home_url, :staged_managed_header_home_url,
                             :managed_header_text, :staged_managed_header_text,
                             :header_footer_css, :staged_header_footer_css,
                             :header, :staged_header, :footer, :staged_footer,
                             :ga_web_property_id, :external_tracking_code, :submitted_external_tracking_code,
                             :favicon_url, :staged_favicon_url, :external_css_url, :staged_external_css_url,
                             :is_sayt_enabled, :fetch_concurrency, :raw_log_access_enabled,
                             :has_staged_content, :locale,
                             :affiliate_feature_addition, :jobs_enabled, :agency,
                             :excluded_domains, :search_engine]
    config.list.columns.exclude virtual_columns
    config.create.columns = [:display_name, :name, :header_footer_css, :header, :footer, :locale]
    config.columns[:is_sayt_enabled].label = "Enable SAYT"
    config.columns[:theme].form_ui = :select
    config.columns[:features].associated_limit = nil
    config.columns[:staged_theme].form_ui = :select
    config.columns[:agency].form_ui = :select
    theme_options = Affiliate::THEMES.keys.collect { |key| [Affiliate::THEMES[key][:display_name], key.to_s] }
    config.columns[:theme].options = { :include_blank => '', :options => theme_options }
    config.columns[:staged_theme].options = { :include_blank => '', :options => theme_options }
    config.action_links.add "analytics", :label => "Analytics", :type => :member, :page => true
    actions.add :export
    config.export.default_deselected_columns = [:header_footer_css,
                                                :staged_header_footer_css,
                                                :header,
                                                :staged_header,
                                                :footer, :staged_footer]
    config.columns[:search_engine].form_ui = :select
    config.columns[:search_engine].options = { :options => %w(Bing Google) }
  end

  def analytics
    redirect_to new_site_queries_path(Affiliate.find params[:id])
  end
end
