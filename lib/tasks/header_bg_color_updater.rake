# frozen_string_literal: true

# DELETE ME: This file can be deleted after SRCH-5176 data migration
# rubocop:disable Metrics/BlockLength
namespace :searchgov do

  desc 'Correct the header_background_color setting for a list of Affiliates via CSV'
  # Usage: rake searchgov:set_header_background_color[fix_header_bg_color.csv]

  task :set_header_background_color, [:csv_file] => [:environment] do |_t, args|
    csv_file = args.csv_file

    ActiveRecord::Base.transaction do
      CSV.foreach(csv_file, headers: true) do |row|
        affiliate_id = row['ID']
        affiliate = Affiliate.find(affiliate_id)
        if affiliate.visual_design_json['header_background_color'].downcase == affiliate.visual_design_json['header_links_background_color'].downcase
          affiliate.visual_design_json['header_background_color'] = affiliate.css_property_hash[:header_background_color]

          affiliate.save!
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
