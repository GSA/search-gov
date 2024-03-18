# frozen_string_literal: true

namespace :searchgov do
  # To update ALL affiliates image content columns
  # rake "searchgov:image_content_updater[all]"

  # To update select ids, add a space separated list of ids
  # rake "searchgov:image_content_updater[1 2 300]"
  desc 'Update image content for all/select affiliates'
  task :image_content_updater, [:ids] => :environment do |_t, args|
    if args[:ids].nil?
      puts "Please provide a space-separated list of affiliate ids or 'all' as a task argument. No affiliates updated."
      next
    end

    image_content_updater = ImageContentUpdater.new
    updated, failed = image_content_updater.update(args[:ids])

    puts "#{updated.count} affiliate(s) updated successfully." if updated.present?
    puts "#{failed.count} affiliate(s) failed to update.  Consult logs for more info." if failed.present?
  end
end
  