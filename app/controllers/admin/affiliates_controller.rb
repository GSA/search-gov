class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.label = 'Sites'
    config.actions.exclude :delete

    attribute_columns = config.columns.reject do |column|
      column.association or column.name =~ /(_created_at|_updated_at|agency_id|css_properties|content_type|file_name|_image|json|keen_scoped_key|label|_logo|_mappings|scope_ids|size|status_id|uses_managed_header_footer)\z/
    end.map(&:name)
    attribute_columns << :agency
    attribute_columns.sort!

    all_columns = attribute_columns
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
    config.list.sorting = { :created_at => :desc }

    [:header_footer_css, :staged_header_footer_css,
     :header, :staged_header, :footer, :staged_footer,
     :external_tracking_code, :submitted_external_tracking_code].each do |c|
      config.columns[c].form_ui = :textarea
    end

    update_columns = %i(status go_live_date affiliate_note)
    update_columns |= attribute_columns.reject { |column| column =~ /\A(api_access_key|created_at|external_css_url|favicon_url|has_staged_content|id|theme|updated_at)\z/i }
    config.update.columns = []

    enable_disable_column_regex = /^(is\_|dap_enabled|force_mobile_format|gets_blended_results|jobs_enabled|raw_log_access_enabled)/.freeze

    config.update.columns.add_subgroup 'Settings' do |name_group|
      name_group.add *update_columns.reject { |column| column =~ enable_disable_column_regex }
      name_group.add :affiliate_feature_addition, :excluded_domains
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Enable/disable Settings' do |name_group|
      name_group.add *update_columns.reject { |column| column !~ enable_disable_column_regex }
      # name_group.add :display_name, :name, :website,
      #                :locale, :affiliate_feature_addition, :excluded_domains
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Display Settings' do |name_group|
      name_group.add :favicon_url, :related_sites_dropdown_label
      name_group.collapsed = true
    end


    config.update.columns.add_subgroup 'Tags' do |name_group|
      name_group.add :tags
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Analytics-Tracking Code' do |name_group|
      name_group.add :ga_web_property_id, :external_tracking_code, :submitted_external_tracking_code
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Dublin Core Mappings' do |name_group|
      name_group.add :dc_contributor, :dc_subject, :dc_publisher
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Legacy Display Settings' do |name_group|
      name_group.add :theme, :has_staged_content,
                     :uses_managed_header_footer, :staged_uses_managed_header_footer,
                     :header_footer_css, :staged_header_footer_css,
                     :header, :staged_header, :footer, :staged_footer,
                     :external_css_url
      name_group.collapsed = true
    end

    excluded_show_columns = %i(footer header header_footer_css staged_footer staged_header staged_header_footer_css)
    show_columns = list_columns
    show_columns |= all_columns.reject { |column| excluded_show_columns.include? column }
    config.show.columns = show_columns

    config.create.columns = [:display_name, :name, :website, :locale]
    config.columns[:theme].form_ui = :select
    config.columns[:features].associated_limit = nil
    config.columns[:agency].form_ui = :select

    theme_options = Affiliate::THEMES.keys
    config.columns[:theme].options = { include_blank: '- select -', options: theme_options }
    config.action_links.add "analytics", :label => "Analytics", :type => :member, :page => true

    config.columns[:locale].form_ui = :select
    config.columns[:locale].options = { options: %w(en es) }

    config.columns[:search_engine].form_ui = :select
    config.columns[:search_engine].options = { :options => %w(Bing Google) }

    config.columns[:tags].form_ui = :select
    config.columns[:tags].set_link 'edit'

    config.columns[:status].form_ui = :select
    config.columns[:status].set_link 'edit'
  end

  def analytics
    redirect_to new_site_queries_path(Affiliate.find params[:id])
  end
end
