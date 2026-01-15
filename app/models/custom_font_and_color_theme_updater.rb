# frozen_string_literal: true

# DELETE ME: This file can be deleted after SRCH-4873 data migration
class CustomFontAndColorThemeUpdater
  VISUAL_DESIGN_FONT = %w[primary_navigation_font_family header_links_font_family footer_and_results_font_family].freeze
  VISUAL_DESIGN_COLOR = %w[button_background_color header_background_color header_secondary_link_color footer_background_color footer_links_text_color header_navigation_background_color active_search_tab_navigation_color header_primary_link_color search_tab_navigation_link_color banner_background_color banner_text_color result_title_color result_title_link_visited_color result_url_color result_description_color].freeze
  CSS_PROPERTY_COLOR  = %i[search_button_background_color header_links_background_color header_text_color footer_background_color footer_background_color footer_links_text_color footer_links_text_color footer_links_text_color navigation_background_color left_tab_text_color navigation_link_color navigation_link_color header_tagline_background_color header_tagline_color title_link_color visited_title_link_color url_link_color description_text_color].freeze

  def update(args)
    ids = args == 'all' ? Affiliate.all.ids : args.split
    update_custom_font_and_color_theme(ids)
  end

  private

  def update_custom_font_and_color_theme(ids)
    updated_list = []
    failed_list = []

    Affiliate.where(id: ids).find_each do |affiliate|
      update_font_and_color(affiliate, updated_list)
    rescue StandardError => e
      failed_list << { affiliate_id: affiliate.id, reason: e.inspect }
    end

    log_completion(updated_list, failed_list)
    [updated_list, failed_list]
  end

  def update_font_and_color(affiliate, updated_list)
    return if affiliate.theme == 'default' || affiliate.visual_design_json != Affiliate::DEFAULT_VISUAL_DESIGN

    update_font_family(affiliate)
    update_affiliate_custom_color_theme(affiliate)
    updated_list << affiliate.id if affiliate.changed?
    affiliate.save
  end

  def update_font_family(affiliate)
    font_family = affiliate.css_property_hash[:font_family]
    Affiliate::FONT_FIELDS.each do |font_key|
      affiliate.visual_design_json[font_key] = get_font_family(font_family)
    end
  end

  def get_font_family(font_family)
    font_families = {
      'Arial, sans-serif' => "'Public Sans Web', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'",
      '"Trebuchet MS", sans-serif' => "'Public Sans Web', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'",
      'Verdana, sans-serif' => "'Public Sans Web', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'",
      'Helvetica, sans-serif' => "'Helvetica Neue', 'Helvetica', 'Roboto', 'Arial', sans-serif",
      'Tahoma, Verdana, Arial, sans-serif' => "'Tahoma', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'"
    }

    font_families[font_family] || font_family
  end

  def update_affiliate_custom_color_theme(affiliate)
    VISUAL_DESIGN_COLOR.each_with_index do |vd, index|
      css_property = affiliate.css_property_hash[CSS_PROPERTY_COLOR[index]] || Affiliate::THEMES[:default][CSS_PROPERTY_COLOR[index]]
      affiliate.visual_design_json[vd] = css_property
    end
    affiliate.visual_design_json['best_bet_background_color'] = '#ffffff' # update color directly here since there is no corresponding key in css_property_hash
    affiliate.visual_design_json
  end

  def log_completion(updated_list, failed_list)
    Rails.logger.info("[custom_font_and_color_theme_updater_task] The following affiliates were updated successfully: #{updated_list}.") if updated_list.present?
    Rails.logger.error("[custom_font_and_color_theme_updater_task] The following affiliates failed to update: #{failed_list}.") if failed_list.present?
  end
end
