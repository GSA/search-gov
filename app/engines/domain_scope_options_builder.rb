module DomainScopeOptionsBuilder
  def self.build(site, site_limits)
    { included_domains: site.site_domains.pluck(:domain),
      excluded_domains: site.excluded_domains.pluck(:domain),
      scope_ids: site.scope_ids_as_array,
      site_limits: site_limits }
  end
end
