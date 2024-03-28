# frozen_string_literal: true

namespace :searchgov do
  # To update ALL affiliates headers and footer columns
  # rake "searchgov:header_and_footer_links_updater[all]"

  # To update select ids, add a space separated list of ids
  # rake "searchgov:header_and_footer_links_updater[1 2 300]"
  desc 'Update header and footer links for all/select affiliates'
  task :header_and_footer_links_updater, [:ids] => :environment do |_t, args|
    if args[:ids].nil?
      puts "Please provide a space-separated list of affiliate ids or 'all' as a task argument. No affiliates updated."
      next
    end

    header_and_footer_links_updater = HeaderAndFooterLinksUpdater.new
    updated, failed = header_and_footer_links_updater.update(args[:ids])

    puts "#{updated.count} affiliate(s) updated successfully." if updated.present?
    puts "#{failed.count} affiliate(s) failed to update.  Consult logs for more info." if failed.present?
  end
end
