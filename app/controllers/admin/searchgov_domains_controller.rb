class Admin::SearchgovDomainsController < Admin::AdminController
  active_scaffold :searchgov_domain do |config|
    config.label = 'Search.gov Domains'
    config.actions = %i[create list search export nested]
    config.create.columns = [:domain]
    config.columns = %i[
      id domain canonical_domain status activity
      urls_count unfetched_urls_count created_at
    ]
    config.nested.add_link(:searchgov_urls, label: "URLs", page: false)
    config.nested.add_link(:sitemaps, page: false)
  end

  def after_create_save(record)
    flash[:info] = "#{record.domain} has been created. Sitemaps will automatically begin indexing."
  end
end
