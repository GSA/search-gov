module DomainScopeOptionsBuilder
  def self.build(site:, site_limits: nil, collection: nil)
    { included_domains: collection ? included_domains(collection) : site.site_domains.pluck(:domain),
      excluded_domains: site.excluded_domains.pluck(:domain),
      scope_ids: site.scope_ids_as_array,
      site_limits: strip_sitelimit_protocol(site_limits) }
  end

  def self.included_domains(collection)
    collection.url_prefixes.map do |url_prefix|
      UrlParser.strip_http_protocols(url_prefix.prefix)
    end.presence
  end

  def self.strip_sitelimit_protocol(site_limits)
    return if site_limits.blank?

    site_limits.split(' ').map do |site_limit|
      UrlParser.strip_http_protocols(site_limit)
    end.join(' ')
  end

end
