class SuperfreshController < ApplicationController
  def index
    request.format = :rss
  end
end
