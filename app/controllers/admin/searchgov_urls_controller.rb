class Admin::SearchgovUrlsController < Admin::AdminController
  active_scaffold :searchgov_url do |config|
    config.label = 'Search.gov URLs'
    config.actions = %i[create list delete export field_search]
    config.columns = %i[id url last_crawl_status last_crawled_at created_at]
    config.create.columns = [:url]
    config.action_links.add 'fetch',
      label: 'Fetch',
      type: :member,
      crud_type: :update,
      method: :post,
      position: false,
      inline: true
    config.delete.link.confirm = "This will remove this URL from the Search.gov index. Are you sure you want to do this?"
    config.field_search.columns = %i[url last_crawl_status]
  end

  def fetch
    process_action_link_action do | record|
      SearchgovUrlFetcherJob.perform_later record
      flash[:info] = "Your URL has been added to the fetching queue."
    end
  end
end
