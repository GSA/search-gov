every 1.month, roles: [:cron] do
  rake 'search:reports:email_monthly_reports'
end

every '35 21 18 12 *', roles: [:cron] do
  rake 'search:reports:email_yearly_reports'
end

every '18 9 * * 1-5', roles: [:cron]  do
  rake 'search:federal_register:import_agencies'
end

every '18 9 * * 1-5', roles: [:cron]  do
  rake 'search:federal_register:import_documents'
end

every '0 2-20 * * *', roles: [:cron] do
  rake "usasearch:sayt_suggestions:compute[#{Time.now.strftime('%Y%m%d')},1000]"
end

every '0 2-20 * * *', roles: [:cron] do
  runner 'SearchgovUrl.counter_culture_fix_counts'
end

every '0 2-20 * * *', roles: [:cron] do
  runner 'usasearch:rss_feed:refresh_affiliate_feeds'
end

every '5 0 * * *', roles: [:cron] do
  rake 'usasearch:sayt_suggestions:compute'
  rake 'usasearch:sayt_suggestions:expire[21]'
end

every '5 0 * * *', roles: [:cron] do
  rake 'usasearch:site_feed_url:refresh_all'
end

every '5 0 * * *', roles: [:cron] do
 rake 'usasearch:user:update_not_active_approval_status'
end

every '5 0 * * *', roles: [:cron] do
  rake 'usasearch:user:warn_set_to_not_approved[76]'
end

every '5 0 * * *', roles: [:cron] do
 rake 'usasearch:user:warn_set_to_not_approved[86]'
end

every '5 0 * * *', roles: [:cron] do
 command "DB_USER=#{ENV['DB_USER']} DB_PASSWORD=#{ENV['DB_PASSWORD']} DB_HOST=#{ENV['DB_HOST']} DB_NAME=#{ENV['DB_NAME']} bin/detect_future_usage"
end

every '5 0 * * *', roles: [:cron] do
 command "DB_USER=#{ENV['DB_USER']} DB_PASSWORD=#{ENV['DB_PASSWORD']} DB_HOST=#{ENV['DB_HOST']} DB_NAME=#{ENV['DB_NAME']} bin/adjust_fetch_concurrency"
end

every '25 2 * * 0', roles: [:cron] do
 rake 'usasearch:sayt_filters:filtered_popular_terms'
end

every '25 2 * * 0', roles: [:cron] do
 rake 'usasearch:medline:load'
end

every '25 2 * * 0', roles: [:cron] do
 rake 'usasearch:rss_feed_urls:enqueue_destroy_all_inactive'
end

every '25 2 * * 0', roles: [:cron] do
 rake 'usasearch:user:update_approval_status'
end
