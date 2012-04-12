class SitemapObserver < ActiveRecord::Observer
  def after_create(sitemap)
    Resque.enqueue(SitemapFetcher, sitemap.id)
  end
end