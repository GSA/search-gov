class Admin::SiteDomainsController < Admin::AdminController
  active_scaffold :site_domain do |config|
    config.actions.exclude :show, :create, :update
    config.action_links.add 'trigger_crawl', :label => 'Crawl', :type => :member, :inline => true
  end

  def trigger_crawl
    Resque.enqueue_with_priority(:low, SiteDomainCrawler, params[:id])
    self.response_body = "How do I get this message to show up in AS?"
    self.content_type = "text/plain"
  end
end
