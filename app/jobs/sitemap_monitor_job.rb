class SitemapMonitorJob < ApplicationJob
  queue_as :sitemap

  def perform
    SearchgovDomain.ok.each do |searchgov_domain|
      searchgov_domain.index_sitemaps
    end
  end
end
