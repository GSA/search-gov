namespace :usasearch do
  namespace :api_cache do
    desc 'Flush old api_cache entries'
    task :cleanup => :environment do
      max_age_minutes = ENV['MAX_AGE_MINUTES'] || 1440
      Rails.logger.info("Starting api_cache cleanup at #{DateTime.now.iso8601}")
      unless Dir["#{ApiCache.file_store_root}/*"].empty?
        Kernel.system("find #{ApiCache.file_store_root}/* -depth -cmin +#{max_age_minutes} -exec rm -r {} \\;") or raise 'could not flush old api_cache entries'
      end
      Rails.logger.info("Finished api_cache cleanup at #{DateTime.now.iso8601}")
    end
  end
end
