class SuperfreshController < ApplicationController
  before_action :set_request_format

  def index
    @superfresh_urls = SuperfreshUrl.uncrawled_urls
  end

  private

  def set_request_format
    request.format = :rss
  end
end
