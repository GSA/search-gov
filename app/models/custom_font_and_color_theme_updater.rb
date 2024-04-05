# frozen_string_literal: true

class CustomFontAndColorThemeUpdater
  VISUAL_DESIGN_FONT = %w[primary_navigation_font_family header_links_font_family footer_and_results_font_family identifier_font_family].freeze
  VISUAL_DESIGN_COLOR = %w[button_background_color header_background_color header_secondary_link_color footer_background_color identifier_background_color footer_links_text_color identifier_heading_color identifier_link_color header_navigation_background_color active_search_tab_navigation_color header_primary_link_color search_tab_navigation_link_color banner_background_color banner_text_color result_title_color result_title_link_visited_color result_url_color result_description_color best_bet_background_color].freeze
  CSS_PROPERTY_COLOR  = [:search_button_background_color, :header_links_background_color, :header_text_color, :footer_background_color, :footer_background_color, :footer_links_text_color, :footer_links_text_color, :footer_links_text_color, :navigation_background_color, :left_tab_text_color, :navigation_link_color, :navigation_link_color, :header_tagline_background_color, :header_tagline_color, :title_link_color, :visited_title_link_color, :url_link_color, :description_text_color, '#ffffff'].freeze

  def update(args)
    ids = args == 'all' ? Affiliate.all.ids : args.split
    update_custom_font_and_color_theme(ids)
  end

  private

  def update_custom_font_and_color_theme(ids)
    updated_list = []
    failed_list = []

    Affiliate.where(id: ids).find_each do |affiliate|
      update_font_and_color(affiliate)
      updated_list << affiliate.id
    rescue StandardError => e
      failed_list << { affiliate_id: affiliate.id, reason: e.inspect }
    end

    log_completion(updated_list, failed_list)
    [updated_list, failed_list]
  end

  def update_font_and_color(affiliate)
    next if affiliate.theme == 'default' || affiliate.visual_design_json != Affiliate::DEFAULT_VISUAL_DESIGN

    update_font_family(affiliate)
    update_affiliate_custom_color_theme(affiliate)
    affiliate.save
  end

  def update_font_family(affiliate)
    font_family = affiliate.css_property_hash[:font_family]
    VISUAL_DESIGN_FONT.each do |font_key|
      affiliate.visual_design_json[font_key] = get_font_family(font_family)
    end
  end

  def get_font_family(font_family)
    "Public Sans Web', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'" if font_family == 'Arial, sans-serif'
    "'Helvetica Neue', 'Helvetica', 'Roboto', 'Arial', sans-serif" if font_family == 'Helvetica, sans-serif'
    "'Tahoma', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'" if font_family == 'Tahoma, Verdana, Arial, sans-serif'
    "'Public Sans Web', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'" if font_family == '"Trebuchet MS", sans-serif'
    "'Public Sans Web', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'" if font_family == 'Verdana, sans-serif'
  end

  def update_affiliate_custom_color_theme(affiliate)
    VISUAL_DESIGN.each_with_index do |vd, index|
      css_property = affiliate.css_property_hash[CSS_PROPERTY[index]] || Affiliate::THEMES[:default][CSS_PROPERTY[index]]
      affiliate.visual_design_json[vd] = css_property
    end
  end

  def log_completion(updated_list, failed_list)
    Rails.logger.info("[custom_font_and_color_theme_updater_task] The following affiliates were updated successfully: #{updated_list}.") if updated_list.present?
    Rails.logger.error("[custom_font_and_color_theme_updater_task] The following affiliates failed to update: #{failed_list}.") if failed_list.present?
  end
end
