class Admin::SearchgovUrlsController < Admin::AdminController
  active_scaffold :searchgov_url do |config|
    config.label = 'Search.gov URLs'
    config.actions = [:create, :list, :delete, :export, :field_search]
    config.columns = [:url, :last_crawl_status, :last_crawled_at]
    config.create.columns = [:url]
    config.action_links.add 'fetch',
      label: 'Fetch',
      type: :member,
      crud_type: :update,
      method: :post,
      position: false,
      inline: true
    config.delete.link.confirm = "This will remove this URL from the Search.gov index. Are you sure you want to do this?"
    config.field_search.columns = :url, :last_crawl_status
  end

  def fetch
    process_action_link_action do | record|
      self.successful = record.fetch
    end
  end
end
