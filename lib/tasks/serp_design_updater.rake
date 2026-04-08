# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :searchgov do
  desc 'Migrate design settings for the redesigned SERP via CSV'
  # Usage: rake searchgov:migrate_designs[site_attributes.csv]

  task :migrate_designs, [:csv_file] => [:environment] do |_t, args|
    csv_file = args.csv_file

    ActiveRecord::Base.transaction do
      CSV.foreach(csv_file, headers: true) do |row|
        affiliate_id = row['ID']
        affiliate = Affiliate.find(affiliate_id)

        create_primary_header_links(row, affiliate)
        create_secondary_header_links(row, affiliate)
        create_footer_links(row, affiliate)

        affiliate.visual_design_json = visual_design_settings(row)
        misc_settings(row, affiliate)

        affiliate.save!
      end
    end
  end

  desc 'Set the display_logo_only setting for a list of Affiliates via CSV'
  # Usage: rake searchgov:set_display_logo_only[site_attributes.csv]

  task :set_display_logo_only, [:csv_file] => [:environment] do |_t, args|
    csv_file = args.csv_file

    ActiveRecord::Base.transaction do
      CSV.foreach(csv_file, headers: true) do |row|
        affiliate_id = row['ID']
        affiliate = Affiliate.find(affiliate_id)
        affiliate.display_logo_only = row['display_logo_only']

        affiliate.save!
      end
    end
  end

  def create_footer_links(row, affiliate)
    13.times do |index|
      title_key = "footer_links #{index} - title"
      url_key = "footer_links #{index} - url"
      footer_link = FooterLink.create(position: index, type: 'FooterLink', title: row[title_key], url: row[url_key], affiliate_id: row['ID'])
      affiliate.footer_links << footer_link if footer_link.valid?
    end
  end

  def create_secondary_header_links(row, affiliate)
    3.times do |index|
      title_key = "secondary_header_links #{index} - title"
      url_key = "secondary_header_links #{index} - url"
      secondary_header_link = SecondaryHeaderLink.create(position: index, type: 'SecondaryHeaderLink', title: row[title_key], url: row[url_key], affiliate_id: row['ID'])
      affiliate.secondary_header_links << secondary_header_link if secondary_header_link.valid?
    end
  end

  def create_primary_header_links(row, affiliate)
    12.times do |index|
      title_key = "primary_header_links #{index} - title"
      url_key = "primary_header_links #{index} - url"
      primary_header_link = PrimaryHeaderLink.create(position: index, type: 'PrimaryHeaderLink', title: row[title_key], url: row[url_key], affiliate_id: row['ID'])
      affiliate.primary_header_links << primary_header_link if primary_header_link.valid?
    end
  end

  def visual_design_settings(row)
    {
      banner_background_color: row['banner_background_color'],
      banner_text_color: row['banner_text_color'],
      header_background_color: row['header_bg_color'],
      header_text_color: row['header_text_color'],
      header_navigation_background_color: row['header_navigation_background_color'],
      header_primary_link_color: row['header_primary_link_color'],
      header_secondary_link_color: row['header_secondary_link_color'],
      page_background_color: row['page_background_color'],
      button_background_color: row['button_background_color'],
      active_search_tab_navigation_color: row['active_search_tab_navigation_color'],
      search_tab_navigation_link_color: row['search_tab_navigation_link_color'],
      best_bet_background_color: row['best_bet_background_color'],
      health_benefits_header_background_color: row['health_benefits_header_background_color'],
      result_title_color: row['result_title_color'],
      result_title_link_visited_color: row['result_title_link_visited_color'],
      result_description_color: row['result_description_color'],
      result_url_color: row['result_url_color'],
      section_title_color: row['section_title_color'],
      footer_background_color: row['footer_background_color'],
      footer_links_text_color: row['footer_link_text_color'],
      footer_and_results_font_family: row['footer_and_results_font_family'],
      header_links_font_family: row['header_links_font_family'],
      primary_navigation_font_family: row['primary_navigation_font_family'],
      primary_navigation_font_weight: row['Primary_navigation_font_weight']
    }.transform_keys(&:to_s)
  end

  def misc_settings(row, affiliate)
    affiliate.display_logo_only = row['display_logo_only']
  end
end
# rubocop:enable Metrics/BlockLength
