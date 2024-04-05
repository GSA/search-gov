# frozen_string_literal: true

namespace :searchgov do
	# To update ALL affiliates custom font and color theme columns
	# rake "searchgov:custom_font_and_color_theme_updater[all]"

	# To update select ids, add a space separated list of ids
	# rake "searchgov:custom_font_and_color_theme_updater[1 2 300]"
	desc 'Update custom color theme links for all/select affiliates'
	task :custom_font_and_font_and_color_theme_updater, [:ids] => :environment do |_t, args|
		if args[:ids].nil?
			puts "Please provide a space-separated list of affiliate ids or 'all' as a task argument. No affiliates updated."
			next
		end

		custom_font_and_color_theme_updater = CustomFontAndColorThemeUpdater.new
		updated, failed = custom_font_and_color_theme_updater.update(args[:ids])

		puts "#{updated.count} affiliate(s) updated successfully." if updated.present?
		puts "#{failed.count} affiliate(s) failed to update.  Consult logs for more info." if failed.present?
	end
end
  