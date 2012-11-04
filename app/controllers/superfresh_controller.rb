class SuperfreshController < ApplicationController
  before_filter :set_request_format

  def index
    delete_them_afterwards = request.user_agent == SuperfreshUrl::MSNBOT_USER_AGENT
    @superfresh_urls = SuperfreshUrl.uncrawled_urls(delete_them_afterwards)
  end

  private

  def set_request_format
    request.format = :rss
  end
end
