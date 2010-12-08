class SuperfreshController < ApplicationController
  def index
    @superfresh_urls = SuperfreshUrl.uncrawled_urls(500)
    SuperfreshUrl.transaction do 
      @superfresh_urls.each do |superfresh_url|
        superfresh_url.update_attributes(:crawled_at => Time.now)
      end
    end if request.user_agent == SuperfreshUrl::MSNBOT_USER_AGENT
    request.format = :rss
  end
end
