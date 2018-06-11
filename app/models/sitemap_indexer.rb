class SitemapIndexer
  attr_reader :searchgov_domain, :domain, :scheme

  def initialize(searchgov_domain:)
    @searchgov_domain = searchgov_domain
    @domain = searchgov_domain.domain
    @scheme = searchgov_domain.scheme
  end

  def index
    Rails.logger.info "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entries_found: sitemap_entries.count).to_json}"
    sitemap_entries.each{ |entry| process_entry(entry) }
    searchgov_domain.index_urls
  end

  private

  def sitemap_entries
    # Eventually we might add an option to the Sitemaps gem to limit the URLS
    # to those strictly adhering to the sitemap protocol, but this should suffice for now
    # https://www.pivotaltracker.com/story/show/157485118
    @sitemap_entries ||= Sitemaps.discover(domain) { |entry| entry.loc.host == domain }.entries
  end

  def process_entry(entry)
    begin
      sitemap_url = url(entry.loc)
      searchgov_url = SearchgovUrl.find_or_initialize_by(url: sitemap_url)
      searchgov_url.update!(lastmod: entry.lastmod)
    rescue => e
      Rails.logger.error "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entry_failed:  sitemap_url, error: e.message).to_json}".red
    end
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
end
