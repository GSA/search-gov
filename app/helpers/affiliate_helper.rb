module AffiliateHelper
  def affiliate_center_breadcrumbs(crumbs)
    aff_breadcrumbs =
      [link_to("Admin Center",home_affiliates_path), crumbs]
    breadcrumbs(aff_breadcrumbs.flatten)
  end

  def site_wizard_header(current_step)
    steps = {:basic_settings => 0, :content_sources => 1, :get_the_code => 2}
    step_contents = ["Step 1. Basic Settings", "Step 2. Set up site", "Step 3. Get the code"]
    image_tag("site_wizard_step_#{steps[current_step] + 1}.png", :alt => "#{step_contents[steps[current_step]]}")
  end

  def render_help_link(help_link)
    link_to(image_tag("help-icon.png", :alt => "Help?", :class => "help-icon", :style => 'height: 3%; width: 3%;'), help_link.help_page_url, :target => "_blank", :id => 'help-link') if help_link
  end

  def render_choose_site_templates(affiliate)
    templates = AffiliateTemplate.all.sort_by(&:name).collect do |template|
      checked = affiliate.staged_affiliate_template_id? ? affiliate.staged_affiliate_template_id == template.id : (template.name == 'Default')
      content = ''
      content << radio_button(:affiliate, :staged_affiliate_template_id, template.id, :checked => checked)
      content << label(:affiliate, "staged_affiliate_template_id_#{template.id}", template.name)
      content << image_tag("affiliate_template_#{template.name.downcase.gsub(' ', '_').underscore}.png")
      content_tag :div, raw(content), :class => 'affiliate-template'
    end
    templates.join
  end

  def render_last_crawl_status(indexed_document)
    return indexed_document.last_crawl_status if indexed_document.last_crawl_status == IndexedDocument::OK_STATUS or indexed_document.last_crawl_status.blank?

    content = ''
    dialog_id = "crawled-url-error-message-#{indexed_document.id}"
    content << link_to('Error', '#', :class => 'crawled-url-dialog-link', :dialog_id => dialog_id)
    content << link_to(content_tag(:span, nil, :class => 'ui-icon ui-icon-newwin'), '#', :class => 'crawled-url-dialog-link', :dialog_id => dialog_id)
    error_message_text = h(indexed_document.url)
    error_message_text << tag(:br)
    error_message_text << h(indexed_document.last_crawl_status)
    content << content_tag(:div, error_message_text.html_safe, :class => 'crawled-url-error-message', :id => dialog_id)
    content.html_safe
  end

  def javascript_include_tag_with_full_path(*sources)
    sources_with_full_path = sources.collect { |source| javascript_full_path(source) }
    javascript_include_tag sources_with_full_path
  end

  def javascript_full_path(source)
    "#{URI.parse(root_url(:protocol => 'http')).merge("/javascripts/#{source}")}"
  end

  def stylesheet_link_tag_with_full_path(*sources)
    sources_with_full_path = sources.collect { |source| "#{URI.parse(root_url(:protocol => 'http')).merge("/stylesheets/#{source}")}" }
    stylesheet_link_tag sources_with_full_path
  end

  def render_affiliate_css_property_value(css_property_hash, property)
    css_property_hash[property].blank? ? Affiliate::DEFAULT_CSS_PROPERTIES[property] : css_property_hash[property]
  end

  def render_managed_header_css_property_value(managed_header_css_properties, property, check_for_nil = true)
    if check_for_nil and managed_header_css_properties.nil? || managed_header_css_properties[property].nil?
      Affiliate::DEFAULT_MANAGED_HEADER_CSS_PROPERTIES[property]
    elsif !check_for_nil and managed_header_css_properties.blank? || managed_header_css_properties[property].blank?
      Affiliate::DEFAULT_MANAGED_HEADER_CSS_PROPERTIES[property]
    else
      managed_header_css_properties[property]
    end
  end

  def render_affiliate_header(affiliate, search_options)
    if affiliate and (search_options.nil? or !search_options[:embedded])
      if affiliate.uses_one_serp? and affiliate.uses_managed_header_footer?
        html = render_managed_header(affiliate)
        if affiliate.managed_header_links.present?
          background_color = "#{render_managed_header_css_property_value(affiliate.managed_header_css_properties, :header_footer_link_background_color)}"
          style = background_color.blank? ? nil : "background-color: #{background_color};"
          html << content_tag(:div, render_managed_links(affiliate.managed_header_links).html_safe, :class => 'managed-header-footer-links-wrapper', :style => style)
        end
        content_tag(:div, html.html_safe, :id => 'header', :class => 'managed') unless html.blank?
      elsif !affiliate.uses_managed_header_footer? and affiliate.header.present?
        content_tag(:div, affiliate.header.html_safe, :id => 'header', :class => 'header-footer')
      end
    end
  end

  def render_managed_header(affiliate)
    content = ''
    unless affiliate.header_image_file_name.blank?
      begin
        image_style = "display: inline-block;#{affiliate.managed_header_text.blank? ? '' : ' float: right;'}"
        content << link_to_unless(affiliate.managed_header_home_url.blank?, image_tag(affiliate.header_image.url, :alt => 'logo', :style => "#{image_style}"), affiliate.managed_header_home_url)
      rescue Exception
        nil
      end
    end

    unless affiliate.managed_header_text.blank?
      color = render_managed_header_css_property_value(affiliate.managed_header_css_properties, :header_text_color)
      style = "color: #{color}; font-family: Georgia, serif; font-size: 50px; display: inline-block; margin: 0 auto;"
      content << link_to_unless(affiliate.managed_header_home_url.blank?, content_tag(:div, affiliate.managed_header_text, :style => style), affiliate.managed_header_home_url)
    end

    background_color = render_managed_header_css_property_value(affiliate.managed_header_css_properties, :header_background_color)
    alignment = affiliate.managed_header_text.blank? ? 'center' : 'left';
    header_style = "text-align: #{alignment};"
    header_style << " background-color: #{background_color};" unless background_color.blank?
    content.blank? ? content : content_tag(:div, content.html_safe, :id => 'managed_header', :style => "#{header_style}").html_safe
  end

  def render_managed_links(links)
    content = ''
    links.each_with_index do |link, index|
      options = { :class => 'first' } if index == 0
      content << content_tag(:li, link_to(link[:title], link[:url], options).html_safe) << "\n"
    end
    content_tag(:ul, content.html_safe, :class => 'managed-header-footer-links')
  end

  def render_affiliate_footer(affiliate, search_options)
    if affiliate and (search_options.nil? or !search_options[:embedded])
      if affiliate.uses_one_serp? and affiliate.uses_managed_header_footer? and affiliate.managed_footer_links.present?
        background_color = "#{render_managed_header_css_property_value(affiliate.managed_header_css_properties, :header_footer_link_background_color)}"
        style = background_color.blank? ? nil : "background-color: #{background_color};"
        html = content_tag(:div, render_managed_links(affiliate.managed_footer_links).html_safe, :class => 'managed-header-footer-links-wrapper', :style => style)
        content_tag(:div, html.html_safe, :id => 'footer', :class => 'managed')
      elsif !affiliate.uses_managed_header_footer? and affiliate.footer.present?
        content_tag(:div, affiliate.footer.html_safe, :id => 'footer', :class => 'header-footer')
      end
    end
  end

  def render_affiliate_stylesheet(affiliate)
    stylesheet_source = affiliate.uses_one_serp? ? "compiled/affiliates/one_serp" : "compiled/affiliates/#{@affiliate.affiliate_template.stylesheet}"
    stylesheet_link_tag stylesheet_source
  end

  def render_affiliate_body_class(affiliate)
    classes = ''
    if affiliate.uses_one_serp?
      classes << "one-serp default #{I18n.locale} "
      classes << 'with-content-border ' if affiliate.show_content_border?
      classes << 'with-content-box-shadow ' if affiliate.show_content_box_shadow?
    else
      classes << "#{@affiliate.affiliate_template.stylesheet} #{I18n.locale}"
    end
    classes
  end

  def render_affiliate_body_style(affiliate)
    return unless affiliate.uses_one_serp?
    style = ''
    background_color =  render_affiliate_css_property_value(affiliate.css_property_hash, :page_background_color)
    background_image = affiliate.page_background_image.url rescue nil if affiliate.page_background_image_file_name.present?
    if background_image.present?
      style << "background: #{background_color} url(#{background_image}) no-repeat center top"
    else
      style << "background-color: #{background_color}"
    end
    style
  end

  def render_staged_color_text_field_tag(affiliate, field_name_symbol)
    staged_css_property_hash = affiliate.staged_theme == 'custom' ? affiliate.staged_css_property_hash : Affiliate::THEMES[affiliate.staged_theme.to_sym]
    disabled = affiliate.staged_theme != 'custom'
    staged_css_property_hash = {} if staged_css_property_hash.nil?
    text_field_tag "affiliate[staged_css_property_hash][#{field_name_symbol}]",
                   render_affiliate_css_property_value(staged_css_property_hash, field_name_symbol),
                   { :disabled => disabled, :class => 'color { hash:true, adjust:false }' }
  end

  def render_staged_managed_header_color_text_field_tag(affiliate, field_name_symbol)
    staged_managed_header_css_properties = affiliate.staged_managed_header_css_properties
    staged_managed_header_css_properties = {} if staged_managed_header_css_properties.nil?
    text_field_tag "affiliate[staged_managed_header_css_properties][#{field_name_symbol}]",
                   render_managed_header_css_property_value(staged_managed_header_css_properties, field_name_symbol),
                   { :class => 'color { hash:true, adjust:false }' }
  end

  def render_staged_check_box_tag(affiliate, field_name_symbol)
    check_box_tag "affiliate[staged_css_property_hash][#{field_name_symbol}]",
                  '1',
                  affiliate.staged_css_property_hash[field_name_symbol] == '1'
  end

  def render_new_site_themes(affiliate)
    themes = Affiliate::THEMES.keys.collect do |theme|
      next if theme == :custom
      selected = affiliate.staged_theme.blank? ? theme == :default : affiliate.staged_theme.to_sym == theme
      content = []
      content << radio_button(:affiliate, :staged_theme, theme, :checked => selected, :class => 'update-css-properties-trigger')
      content << label(:affiliate, "staged_theme_#{theme}", Affiliate::THEMES[theme][:display_name])
      content << image_tag("affiliates/themes/#{theme}.png", :class => 'css-properties-image-trigger')
      content_tag :div, content.join("\n").html_safe, :class => 'theme'
    end
    content_tag(:div, themes.join("\n").html_safe, :class => 'themes')
  end

  def render_site_themes(affiliate)
    themes = Affiliate::THEMES.keys.collect do |theme|
      content = []

      selected = affiliate.staged_theme.to_sym == theme
      content << radio_button(:affiliate, :staged_theme, theme, :checked => selected, :class => 'update-css-properties-trigger')
      content << label(:affiliate, "staged_theme_#{theme}", Affiliate::THEMES[theme][:display_name])

      content << image_tag("affiliates/themes/#{theme}.png", :class => 'css-properties-image-trigger')
      content << submit_tag("Customize", :type => 'button', :name => 'customize', :class => 'customize-theme-button') unless theme == :custom
      theme_class = 'theme'
      theme_class << ' hidden-custom-theme' if theme == :custom and affiliate.staged_theme.to_sym != :custom
      data = theme == :custom ? nil : Affiliate::THEMES[theme].to_json
      content_tag :div, content.join("\n").html_safe, :data => data, :class => theme_class
    end
    content_tag(:div, themes.join("\n").html_safe, :class => 'themes')
  end

  def render_connected_affiliate_links(affiliate, query)
    return if affiliate.connections.blank?
    links = []
    affiliate.connections.each do |connection|
      links << link_to(connection.label,
                       search_path(:affiliate => connection.connected_affiliate.name, :query => query),
                       :class => 'updatable')
    end
    links.join("\n").html_safe
  end
end
