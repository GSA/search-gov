class SiteDomainCrawler
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(site_domain_id)
    return unless (site_domain = SiteDomain.find_by_id(site_domain_id))
    site_domain.populate
    site_domain.affiliate.refresh_indexed_documents('unfetched')
  end
end