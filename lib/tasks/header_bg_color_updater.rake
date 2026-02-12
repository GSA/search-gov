# frozen_string_literal: true

# DELETE ME: This file can be deleted after SRCH-5176 data migration

VISUAL_DESIGN_COLOR = %w[
  button_background_color header_background_color header_secondary_link_color
  footer_background_color footer_links_text_color header_navigation_background_color
  active_search_tab_navigation_color header_primary_link_color search_tab_navigation_link_color
  banner_background_color banner_text_color result_title_color result_title_link_visited_color
  result_url_color result_description_color
].freeze

CSS_PROPERTY_COLOR = %i[
  search_button_background_color header_background_color header_text_color footer_background_color
  footer_background_color footer_links_text_color footer_links_text_color footer_links_text_color
  navigation_background_color left_tab_text_color navigation_link_color navigation_link_color
  header_tagline_background_color header_tagline_color title_link_color visited_title_link_color
  url_link_color description_text_color
].freeze

namespace :searchgov do
  desc 'Correct the header_background_color setting for a list of Affiliates via CSV'
  # Usage: rake searchgov:set_header_background_color[fix_header_bg_color.csv]

  task :set_header_background_color, [:csv_file] => [:environment] do |_t, args|
    csv_file = args.csv_file

    ActiveRecord::Base.transaction do
      CSV.foreach(csv_file, headers: true) do |row|
        affiliate_id = row['ID']
        affiliate = Affiliate.find(affiliate_id)
        update_affiliate_custom_color_theme(affiliate)
        affiliate.save!
      end
    end
  end

  def update_affiliate_custom_color_theme(affiliate)
    VISUAL_DESIGN_COLOR.each_with_index do |vd, index|
      css_property = affiliate.css_property_hash[CSS_PROPERTY_COLOR[index]] || Affiliate::THEMES[:default][CSS_PROPERTY_COLOR[index]]
      affiliate.visual_design_json[vd] = css_property
    end
    affiliate.visual_design_json['best_bet_background_color'] = '#ffffff' # update color directly here since there is no corresponding key in css_property_hash
    affiliate.visual_design_json
  end
end
