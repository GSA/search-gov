class SitemapIndexer
  attr_reader :domain, :delay, :scheme

  def initialize(domain:, delay: 10, scheme: 'https')
    @domain = domain
    @delay = delay
    @scheme = scheme
  end

  def index
    sitemap = Sitemaps.discover(domain)
    Rails.logger.info "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entries_found: sitemap.entries.count).to_json}"
    valid_entries(sitemap.entries).each{ |entry| process_entry(entry) }
  end

  private

  def process_entry(entry)
    begin
      sitemap_url = url(entry.loc)
      searchgov_url = SearchgovUrl.find_or_create_by!(url: sitemap_url)
      if !searchgov_url.fetched? || outdated?(entry.lastmod, searchgov_url.last_crawled_at)
        searchgov_url.fetch
        Rails.logger.info "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entry_updated: searchgov_url.url).to_json}"
        sleep(delay)
      end
    rescue => e
      Rails.logger.error "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entry_failed:  sitemap_url, error: e.message).to_json}".red
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

  def url(uri)
    uri.scheme = scheme
    uri.to_s
  end

  # Eventually we might add an option to the Sitemaps gem to limit the URLS
  # to those strictly adhering to the sitemap protocol, but this should suffice for now
  # https://www.pivotaltracker.com/story/show/157485118
  def valid_entries(entries)
    entries.select{ |entry| entry.loc.host == domain }
  end
end
