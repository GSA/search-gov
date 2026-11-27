# Whenever crontab for Capistrano :cron hosts.
# Recurring Resque jobs live in config/resque_schedule.yml on crawler hosts.
# Do not add them here.

# every '0 2-20 * * *', roles: [:cron] do
#   rake "usasearch:sayt_suggestions:compute[#{Time.now.strftime('%Y%m%d')},1000]"
# end

# every '5 0 * * *', roles: [:cron] do
#   rake 'usasearch:sayt_suggestions:compute'
#   rake 'usasearch:sayt_suggestions:expire[21]'
# end

# every '5 0 * * *', roles: [:cron] do
#   rake 'usasearch:site_feed_url:refresh_all'
# end

# every '5 0 * * *', roles: [:cron] do
#  command "DB_USER=#{ENV['DB_USER']} DB_PASSWORD=#{ENV['DB_PASSWORD']} DB_HOST=#{ENV['DB_HOST']} DB_NAME=#{ENV['DB_NAME']} bin/detect_future_usage"
# end

# every '5 0 * * *', roles: [:cron] do
#  command "DB_USER=#{ENV['DB_USER']} DB_PASSWORD=#{ENV['DB_PASSWORD']} DB_HOST=#{ENV['DB_HOST']} DB_NAME=#{ENV['DB_NAME']} bin/adjust_fetch_concurrency"
# end

# # OpenSearchDeleteByQueryJob - Run every day at 4AM UTC (11PM ET)
# every '0 4 * * *', roles: [:cron] do
#   runner 'OpenSearchDeleteByQueryJob.perform_later'
# end
