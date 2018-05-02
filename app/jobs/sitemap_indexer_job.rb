class SitemapIndexerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(domain:, delay:)
    SitemapIndexer.new(domain: domain, delay: delay)
  end
end
