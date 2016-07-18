class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.label = 'Sites'
    config.actions.exclude :delete, :search
    config.actions.add :field_search
    config.field_search.columns = :id, :name, :display_name, :website

    attribute_columns = config.columns.reject do |column|
      column.association or column.name =~ /(_created_at|_updated_at|agency_id|css_properties|content_type|file_name|_image|json|label|_logo|_mappings|scope_ids|size|status_id|uses_managed_header_footer|active_template_id|template_schema)\z/
    end.map(&:name)
    attribute_columns << :agency
    attribute_columns.sort!

    all_columns = attribute_columns
    all_columns |= %i(mobile_logo_url header_image_url uses_managed_header_footer staged_uses_managed_header_footer)

    virtual_columns = %i(dc_contributor dc_subject dc_publisher
                         last_month_query_count
                         header_footer_css staged_header_footer_css header staged_header footer staged_footer
                         features external_tracking_code submitted_external_tracking_code
                         header_tagline_font_family header_tagline_font_size header_tagline_font_style
                         related_sites_dropdown_label footer_fragment)
    all_columns |= virtual_columns
    config.columns = all_columns

    list_columns = %i(id display_name name website site_domains nutshell templates created_at updated_at recent_user_activity)
    config.list.columns = list_columns

    export_columns = [list_columns, all_columns].flatten.uniq
    export_columns.reject! { |c| [:nutshell, :templates].include?(c) }
    actions.add :export
    config.export.columns = export_columns
    config.export.default_deselected_columns = %i(api_access_key
                                                  dc_contributor
                                                  dc_subject
                                                  dc_publisher
                                                  external_css_url
                                                  external_tracking_code
                                                  fetch_concurrency
                                                  footer
                                                  footer_fragment
                                                  ga_web_property_id
                                                  has_staged_content
                                                  header
                                                  header_footer_css
                                                  header_tagline_font_family
                                                  header_tagline_font_size
                                                  header_tagline_font_style
                                                  last_month_query_count
                                                  navigation_dropdown_label
                                                  related_sites_dropdown_label
                                                  staged_footer
                                                  staged_header
                                                  staged_header_footer_css
                                                  submitted_external_tracking_code
                                                  staged_uses_managed_header_footer
                                                  theme
                                                  uses_managed_header_footer)


    config.list.sorting = { :created_at => :desc }

    [:header_footer_css, :staged_header_footer_css,
     :header, :staged_header, :footer, :staged_footer,
     :external_tracking_code, :submitted_external_tracking_code].each do |c|
      config.columns[c].form_ui = :textarea
    end

    update_columns = attribute_columns.reject { |column| column =~ /\A(api_access_key|created_at|external_css_url|favicon_url|has_staged_content|id|nutshell_id|status_id|theme|updated_at)\z/i }
    config.update.columns = []
    enable_disable_column_regex = /^(is\_|dap_enabled|force_mobile_format|gets_blended_results|gets_commercial_results_on_blended_search|jobs_enabled|raw_log_access_enabled|search_consumer_search_enabled|gets_i14y_results)/.freeze

    config.update.columns.add_subgroup 'Settings' do |name_group|
      name_group.add *update_columns.reject { |column| column =~ enable_disable_column_regex }
      name_group.add :affiliate_feature_addition, :excluded_domains, :i14y_memberships
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Enable/disable Settings' do |name_group|
      name_group.add *update_columns.reject { |column| column !~ enable_disable_column_regex }
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Display Settings' do |name_group|
      display_columns = %i(footer_fragment
                           header_tagline_font_family
                           header_tagline_font_size
                           header_tagline_font_style
                           no_results_pointer
                           page_one_more_results_pointer
                           navigation_dropdown_label
                           related_sites_dropdown_label)
      name_group.add *display_columns
      name_group.collapsed = true
    end


    config.update.columns.add_subgroup 'Analytics-Tracking Code' do |name_group|
      name_group.add :ga_web_property_id, :domain_control_validation_code,
                     :external_tracking_code, :submitted_external_tracking_code
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Dublin Core Mappings' do |name_group|
      name_group.add :dc_contributor, :dc_subject, :dc_publisher
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Legacy Display Settings' do |name_group|
      name_group.add :has_staged_content,
                     :uses_managed_header_footer, :staged_uses_managed_header_footer,
                     :header_footer_css, :staged_header_footer_css,
                     :header, :staged_header, :footer, :staged_footer,
                     :external_css_url
      name_group.collapsed = true
    end

    config.action_links.add "analytics", :label => "Analytics", :type => :member, :page => true

    excluded_show_columns = %i(footer header header_footer_css staged_footer staged_header staged_header_footer_css)
    show_columns = list_columns
    show_columns |= all_columns.reject { |column| excluded_show_columns.include? column }
    config.show.columns = show_columns

    config.create.columns = [:display_name, :name, :website, :locale]

    config.columns[:agency].form_ui = :select

    config.columns[:favicon_url].label = 'Favicon URL'
    config.columns[:features].associated_limit = nil

    config.columns[:footer_fragment].form_ui = :textarea

    config.columns[:header_image_url].label = 'Legacy Logo URL'

    config.columns[:header_tagline_font_family].form_ui = :select
    config.columns[:header_tagline_font_family].options = { options: HeaderTaglineFontFamily::ALL }

    config.columns[:header_tagline_font_size].description = 'Value should be in em. Default value: 1.3em'

    config.columns[:header_tagline_font_style].form_ui = :select
    config.columns[:header_tagline_font_style].options = { options: %w(italic normal) }

    config.columns[:locale].form_ui = :select
    config.columns[:locale].options = { options: Language.order(:name).pluck(:code) }

    config.columns[:mobile_logo_url].label = 'Logo URL'

    config.columns[:search_engine].form_ui = :select
    config.columns[:search_engine].options = { :options => %w(Azure Bing Google) }

    config.columns[:theme].form_ui = :select
    config.columns[:theme].options = { include_blank: '- select -',
                                       options: Affiliate::THEMES.keys }

    config.columns[:website].label = 'Homepage URL'
  end

  def analytics
    redirect_to new_site_queries_path(Affiliate.find params[:id])
  end

  def after_update_save(record)
    NutshellAdapter.new.push_site record
  end
end
