class SearchgovUrlFetcherJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_url:)
    searchgov_url.fetch
  end
end

