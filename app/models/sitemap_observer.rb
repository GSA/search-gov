class SitemapObserver < ActiveRecord::Observer
  def after_save(sitemap)
    Resque.enqueue(SitemapFetcher, sitemap.id)
  end
end