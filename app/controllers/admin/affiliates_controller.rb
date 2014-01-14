class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.label = 'Sites'
    config.actions.exclude :delete
    config.columns = [:id, :display_name, :name, :status, :tags, :site_domains, :affiliate_note, :created_at, :updated_at]
    config.columns[:affiliate_note].label = 'Note'
    config.list.sorting = { :display_name => :asc }
    virtual_columns = [:go_live_date,
                       :header_footer_css, :staged_header_footer_css, :header, :staged_header, :footer, :staged_footer,
                       :features, :external_tracking_code, :submitted_external_tracking_code]
    config.columns << virtual_columns

    [:header_footer_css, :staged_header_footer_css,
     :header, :staged_header, :footer, :staged_footer,
     :external_tracking_code, :submitted_external_tracking_code].each do |c|
      config.columns[c].form_ui = :textarea
    end

    config.update.columns = [:display_name, :name,
                             :tags, :status, :go_live_date, :affiliate_note,
                             :is_sayt_enabled, :fetch_concurrency, :raw_log_access_enabled, :dap_enabled,
                             :locale,
                             :affiliate_feature_addition, :jobs_enabled, :agency,
                             :excluded_domains, :search_engine]

    config.update.columns.add_subgroup 'Analytics & Tracking Code' do |name_group|
      name_group.add :ga_web_property_id, :external_tracking_code, :submitted_external_tracking_code
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Theme, Header, Footer & URLs' do |name_group|
      name_group.add :theme, :has_staged_content,
                     :uses_managed_header_footer, :staged_uses_managed_header_footer,
                     :header_footer_css, :staged_header_footer_css,
                     :header, :staged_header, :footer, :staged_footer,
                     :favicon_url, :external_css_url
      name_group.collapsed = true
    end

    config.list.columns.exclude virtual_columns
    config.create.columns = [:display_name, :name, :header_footer_css, :header, :footer, :locale]
    config.columns[:is_sayt_enabled].label = "Enable SAYT"
    config.columns[:theme].form_ui = :select
    config.columns[:features].associated_limit = nil
    config.columns[:agency].form_ui = :select
    theme_options = Affiliate::THEMES.keys.collect { |key| [Affiliate::THEMES[key][:display_name], key.to_s] }
    config.columns[:theme].options = { :include_blank => '', :options => theme_options }
    config.action_links.add "analytics", :label => "Analytics", :type => :member, :page => true
    actions.add :export
    config.export.default_deselected_columns = [:header_footer_css,
                                                :staged_header_footer_css,
                                                :header,
                                                :staged_header,
                                                :footer, :staged_footer]
    config.columns[:search_engine].form_ui = :select
    config.columns[:search_engine].options = { :options => %w(Bing Google) }

    config.columns[:tags].form_ui = :select
    config.columns[:tags].set_link 'edit'

    config.columns[:status].form_ui = :select
    config.columns[:status].options = { include_blank: false, options: Status.all.map { |s| [s.name, s.id.to_s] } }
    config.columns[:status].set_link 'edit'
    config.columns[:status].includes = [:status]
    config.columns[:status].sort_by sql: 'statuses.name'
  end

  def analytics
    redirect_to new_site_queries_path(Affiliate.find params[:id])
  end
end
