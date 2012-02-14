module AffiliateHelper
  def affiliate_center_breadcrumbs(crumbs)
    aff_breadcrumbs =
      [link_to("Affiliate Program", affiliates_path), link_to("Affiliate Center",home_affiliates_path), crumbs]
    breadcrumbs(aff_breadcrumbs.flatten)
  end

  def site_wizard_header(current_step)
    steps = {:basic_settings => 0, :content_sources => 1, :get_the_code => 2}
    step_contents = ["Step 1. Basic Settings", "Step 2. Set up site", "Step 3. Get the code"]
    image_tag("site_wizard_step_#{steps[current_step] + 1}.png", :alt => "#{step_contents[steps[current_step]]}", :style => 'width: 680px;')
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

  def render_affiliate_header(affiliate, search_options)
    if affiliate and (search_options.nil? or !search_options[:embedded])
      if affiliate.header.blank?
        return render_default_affiliate_header(affiliate)
      else
        return affiliate.header.html_safe
      end
    end
  end

  def render_default_affiliate_header(affiliate)
    if affiliate.uses_one_serp?
      font_family = render_affiliate_css_property_value(affiliate.css_property_hash, :font_family)
      color = render_affiliate_css_property_value(affiliate.css_property_hash, :search_button_text_color)
      background_color = render_affiliate_css_property_value(affiliate.css_property_hash, :search_button_background_color)
      style = "font-family: Georgia, serif; font-size: 50px; color: #{color}; background-color: #{background_color}; margin: 0 auto 30px; padding: 10px; width: 940px;"
      content_tag :div, affiliate.display_name, :id => 'default-header', :style => style
    else
      ""
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

  def render_staged_color_text_field_tag(affiliate, field_name_symbol)
    staged_css_property_hash = affiliate.staged_theme == 'custom' ? affiliate.staged_css_property_hash : Affiliate::THEMES[affiliate.staged_theme.to_sym]
    disabled = affiliate.staged_theme != 'custom'
    staged_css_property_hash = {} if staged_css_property_hash.nil?
    text_field_tag "affiliate[staged_css_property_hash][#{field_name_symbol}]",
                   render_affiliate_css_property_value(staged_css_property_hash, field_name_symbol),
                   { :disabled => disabled, :class => 'color { hash:true, adjust:false }' }
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
end
