class SitemapIndexerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(searchgov_domain:)
    SitemapIndexer.new(searchgov_domain: searchgov_domain).index
  end
end
