# frozen_string_literal: true

namespace :searchgov do
  # To update ALL affiliates with non-null visual design columns
  # rake "searchgov:font_and_color_updater[all]"

  # To update select ids, add a space separated list of ids
  # rake "searchgov:font_and_color_updater[1 2 300]"
  desc 'Update visual_design_json (fonts and colors) settings for all/select affiliates'
  task :font_and_color_updater, [:ids] => :environment do |_t, args|
    if args[:ids].nil?
      puts "Please provide a space-separated list of affiliate ids or 'all' as a task argument. No affiliates updated."
      next
    end

    font_and_color_updater = FontAndColorUpdater.new
    updated, failed = font_and_color_updater.update(args[:ids])

    puts "#{updated.count} affiliate(s) updated successfully." if updated.present?
    puts "#{failed.count} affiliate(s) failed to update.  Consult logs for more info." if failed.present?
  end
end
