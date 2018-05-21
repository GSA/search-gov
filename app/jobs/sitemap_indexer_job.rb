class SitemapIndexerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(searchgov_domain)
    searchgov_domain.index_sitemap
  end
end
