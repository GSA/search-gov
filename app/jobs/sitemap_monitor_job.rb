class SitemapMonitorJob < ActiveJob::Base
  queue_as :searchgov

  def perform
    SearchgovDomain.ok.each do |searchgov_domain|
      searchgov_domain.index_sitemaps
    end
  end
end
