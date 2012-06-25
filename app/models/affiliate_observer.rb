class AffiliateObserver < ActiveRecord::Observer
  observe :affiliate

  def after_create(affiliate)
    image_search_label = affiliate.build_image_search_label
    image_search_label.save!

    crawl_domain(affiliate.site_domains.first) if affiliate.site_domains.count == 1
  end

  private
    
  def crawl_domain(site_domain)
    Resque.enqueue_with_priority(:low, SiteDomainCrawler, site_domain.id)
  end
end
