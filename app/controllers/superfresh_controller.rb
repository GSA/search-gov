class SuperfreshController < ApplicationController
  def index
    @feed_id = (params[:feed_id] || "1").to_i
    if @feed_id == 1
      @superfresh_urls = SuperfreshUrl.uncrawled_urls(500)
      SuperfreshUrl.transaction do 
        @superfresh_urls.each do |superfresh_url|
          superfresh_url.update_attributes(:crawled_at => Time.now)
        end
      end if request.user_agent == SuperfreshUrl::MSNBOT_USER_AGENT
    else
      @superfresh_urls = []
    end
    request.format = :rss
  end
end
