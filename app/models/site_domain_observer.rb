class SiteDomainObserver < ActiveRecord::Observer
  def after_destroy(site_domain)
    revalidate_associated_indexed_documents(site_domain) unless site_domain.affiliate.site_domains.empty?
  end

  def after_update(site_domain)
    revalidate_associated_indexed_documents(site_domain)
  end

  private

  def revalidate_associated_indexed_documents(site_domain)
    site_domain.affiliate.indexed_documents.select(:id).each { |indexed_document| Resque.enqueue(IndexedDocumentValidator, indexed_document.id) }
  end
end