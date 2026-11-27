# Whenever crontab for Capistrano :cron hosts.
# Recurring Resque jobs live in config/resque_schedule.yml on crawler hosts.
# Do not add them here.

# every '5 0 * * *', roles: [:cron] do
#  command "DB_USER=#{ENV['DB_USER']} DB_PASSWORD=#{ENV['DB_PASSWORD']} DB_HOST=#{ENV['DB_HOST']} DB_NAME=#{ENV['DB_NAME']} bin/detect_future_usage"
# end

# every '5 0 * * *', roles: [:cron] do
#  command "DB_USER=#{ENV['DB_USER']} DB_PASSWORD=#{ENV['DB_PASSWORD']} DB_HOST=#{ENV['DB_HOST']} DB_NAME=#{ENV['DB_NAME']} bin/adjust_fetch_concurrency"
# end
