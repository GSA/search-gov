class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.label = 'Sites'
    config.actions.exclude :delete

    all_columns = config.columns.reject do |column|
      column.association or column.name =~ /(_created_at|_updated_at|agency_id|css_properties|content_type|file_name|_image|json|key|label|_logo|_mappings|scope_ids|size|status_id|uses_managed_header_footer)\z/
    end.map(&:name)
    all_columns << :agency
    all_columns.sort!

    all_columns |= %i(mobile_logo_url header_image_url uses_managed_header_footer staged_uses_managed_header_footer)

    virtual_columns = [:dc_contributor, :dc_subject, :dc_publisher,
                       :go_live_date, :last_month_query_count,
                       :header_footer_css, :staged_header_footer_css, :header, :staged_header, :footer, :staged_footer,
                       :features, :external_tracking_code, :submitted_external_tracking_code]
    all_columns |= virtual_columns
    config.columns = all_columns

    list_columns = %i(id display_name name website status tags site_domains affiliate_note created_at updated_at)
    config.list.columns = list_columns

    export_columns = [list_columns, all_columns].flatten.uniq
    actions.add :export
    config.export.columns = export_columns
    config.export.default_deselected_columns = [:dc_contributor,
                                                :dc_subject,
                                                :dc_publisher,
                                                :external_tracking_code,
                                                :fetch_concurrency,
                                                :footer,
                                                :ga_web_property_id,
                                                :has_staged_content,
                                                :header,
                                                :header_footer_css,
                                                :last_month_query_count,
                                                :staged_footer,
                                                :staged_header,
                                                :staged_header_footer_css,
                                                :submitted_external_tracking_code,
                                                :staged_uses_managed_header_footer,
                                                :uses_managed_header_footer]

    config.columns[:affiliate_note].label = 'Note'
    config.columns[:website].label = 'Homepage URL'
    config.columns[:mobile_logo_url].label = 'Logo URL'
    config.columns[:header_image_url].label = 'Legacy Logo URL'
    config.list.sorting = { :display_name => :asc }

    [:header_footer_css, :staged_header_footer_css,
     :header, :staged_header, :footer, :staged_footer,
     :external_tracking_code, :submitted_external_tracking_code].each do |c|
      config.columns[c].form_ui = :textarea
    end

    config.update.columns = [:status, :go_live_date, :affiliate_note,
                             :force_mobile_format, :is_bing_image_search_enabled,
                             :is_federal_register_document_govbox_enabled,
                             :dap_enabled, :jobs_enabled,
                             :agency, :search_engine, :raw_log_access_enabled, :fetch_concurrency, :tags]

    config.update.columns.add_subgroup 'Settings' do |name_group|
      name_group.add :display_name, :name, :website,
                     :is_sayt_enabled, :locale, :affiliate_feature_addition, :excluded_domains
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Analytics-Tracking Code' do |name_group|
      name_group.add :ga_web_property_id, :external_tracking_code, :submitted_external_tracking_code
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Theme-Header-Footer-URLs' do |name_group|
      name_group.add :theme, :has_staged_content,
                     :uses_managed_header_footer, :staged_uses_managed_header_footer,
                     :header_footer_css, :staged_header_footer_css,
                     :header, :staged_header, :footer, :staged_footer,
                     :favicon_url, :external_css_url
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Dublin Core Mappings' do |name_group|
      name_group.add :dc_contributor, :dc_subject, :dc_publisher
      name_group.collapsed = true
    end

    config.create.columns = [:display_name, :name, :website, :locale]
    config.columns[:is_sayt_enabled].label = "Enable SAYT"
    config.columns[:theme].form_ui = :select
    config.columns[:features].associated_limit = nil
    config.columns[:agency].form_ui = :select

    theme_options = Affiliate::THEMES.keys.collect { |key| [Affiliate::THEMES[key][:display_name], key.to_s] }
    config.columns[:theme].options = { :include_blank => '', :options => theme_options }
    config.action_links.add "analytics", :label => "Analytics", :type => :member, :page => true

    config.columns[:search_engine].form_ui = :select
    config.columns[:search_engine].options = { :options => %w(Bing Google) }

    config.columns[:tags].form_ui = :select
    config.columns[:tags].set_link 'edit'

    config.columns[:status].form_ui = :select
    config.columns[:status].set_link 'edit'
    config.columns[:status].includes = [:status]
    config.columns[:status].sort_by sql: 'statuses.name'
  end

  def analytics
    redirect_to new_site_queries_path(Affiliate.find params[:id])
  end
end
