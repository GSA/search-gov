class SuperfreshController < ApplicationController
  def index
    SuperfreshUrl.transaction do 
      @superfresh_urls = SuperfreshUrl.uncrawled_urls
      @superfresh_urls.each do |superfresh_url|
        superfresh_url.update_attributes(:crawled_at => Time.now)
      end
    end
    request.format = :rss
  end
end
