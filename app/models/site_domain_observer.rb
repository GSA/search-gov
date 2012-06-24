class SiteDomainObserver < ActiveRecord::Observer
  def after_destroy(site_domain)
    revalidate_associated_indexed_documents(site_domain) unless site_domain.affiliate.site_domains.empty?
  end

  def after_update(site_domain)
    revalidate_associated_indexed_documents(site_domain)
  end

  def after_create(site_domain)
    revalidate_associated_indexed_documents(site_domain) if site_domain.affiliate.site_domains.count == 1
    crawl_domain(site_domain) if site_domain.affiliate.site_domains.count == 1
  end

  private

  def revalidate_associated_indexed_documents(site_domain)
    site_domain.affiliate.indexed_documents.each{ |indexed_document| Resque.enqueue(IndexedDocumentValidator, indexed_document.id)}
  end

  def crawl_domain(site_domain)
    Resque.enqueue_with_priority(:low, SiteDomainCrawler, site_domain.id)
  end
end