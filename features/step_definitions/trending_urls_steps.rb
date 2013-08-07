And(/^the following trending URLs exist:$/) do |table|
  redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
  redis.flushdb
  table.hashes.each do |hash|
    redis.sadd("TrendingUrls:#{hash[:affiliate_name]}",hash[:trending_urls].split(','))
  end
end

And(/^the following hourly URL counts exist:$/) do |table|
  redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
  table.hashes.each do |hash|
    redis.zadd("UrlCounts:#{(Time.now.utc - (3600 * hash[:hours_ago].to_i)).strftime("%Y%m%d%H")}:#{hash[:affiliate_name]}", hash[:count].to_i, hash[:url])
  end
end

And(/^no trending URLs exist/) do
  redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
  redis.flushdb
end