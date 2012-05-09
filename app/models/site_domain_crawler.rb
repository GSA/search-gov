class SiteDomainCrawler
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(site_domain_id)
    return unless (site_domain = SiteDomain.find_by_id(site_domain_id))
    site_domain.populate
  end
end