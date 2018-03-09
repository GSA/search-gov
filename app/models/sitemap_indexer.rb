class SitemapIndexer
  attr_reader :domain, :delay

  def initialize(domain:, delay: 10)
    @domain = domain
    @delay = delay
  end

  def index
    sitemap = Sitemaps.discover(domain)
    sitemap.entries.each{ |entry| process_entry(entry) }
  end

  private

  def process_entry(entry)
    searchgov_url = SearchgovUrl.find_or_create_by(url: entry.loc.to_s)
    if !searchgov_url.fetched? || outdated?(entry.lastmod, searchgov_url.last_crawled_at)
      searchgov_url.fetch
      sleep(delay)
    end
  end

  def outdated?(lastmod, last_crawled_at)
    lastmod && lastmod > last_crawled_at
  end
end
