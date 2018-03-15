class SitemapIndexer
  attr_reader :domain, :delay

  def initialize(domain:, delay: 10)
    @domain = domain
    @delay = delay
  end

  def index
    sitemap = Sitemaps.discover(domain)
    Rails.logger.info "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entries_found: sitemap.entries.count).to_json}"
    sitemap.entries.each{ |entry| process_entry(entry) }
    SearchgovUrl.fetch_new(delay: delay)
  end

  private

  def process_entry(entry)
    begin
      searchgov_url = SearchgovUrl.find_or_create_by(url: entry.loc.to_s)
      if !searchgov_url.fetched? || outdated?(entry.lastmod, searchgov_url.last_crawled_at)
        searchgov_url.fetch
        Rails.logger.info "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entry_updated: searchgov_url.url).to_json}"
        sleep(delay)
      end
    rescue => e
      Rails.logger.error "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entry_failed:  searchgov_url.url, error: e).to_json}"
    end
  end

  def outdated?(lastmod, last_crawled_at)
    lastmod && lastmod > last_crawled_at
  end

  def log_info
    {
      time: Time.now.utc.to_formatted_s(:db),
      domain: domain
    }
  end
end
