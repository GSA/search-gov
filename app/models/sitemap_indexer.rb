class SitemapIndexer
  attr_reader :uri, :domain, :scheme

  def initialize(sitemap_url:)
    @uri = URI(sitemap_url)
    @domain = uri.host
    @scheme = uri.scheme
  end

  def index
    sitemaps.any? ? enqueue_sitemaps : process_entries
  end

  private

  def sitemaps
    @sitemaps ||= Sitemaps.parse(sitemap).sitemaps
  end

  def sitemap_entries
    # Eventually we might add an option to the Sitemaps gem to limit the URLS
    # to those strictly adhering to the sitemap protocol, but this should suffice for now
    # https://www.pivotaltracker.com/story/show/157485118
    @sitemap_entries ||= Sitemaps.parse(sitemap).entries.select do |entry|
      entry.loc.host == domain
    end
  end

  def process_entries
    skip_counter_callbacks
    Rails.logger.info "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entries_found: sitemap_entries.count).to_json}"
    sitemap_entries.each{ |entry| process_entry(entry) }
    SearchgovDomain.find_by(domain: domain).index_urls
  ensure
    set_counter_callbacks
    SearchgovUrl.counter_culture_fix_counts
  end

  def process_entry(entry)
    begin
      sitemap_url = UrlParser.update_scheme(entry.loc, scheme)
      searchgov_url = SearchgovUrl.find_or_initialize_by(url: sitemap_url)
      searchgov_url.update!(lastmod: entry.lastmod)
    rescue => e
      Rails.logger.error "[Searchgov SitemapIndexer] #{log_info.merge(sitemap_entry_failed:  sitemap_url, error: e.message).to_json}".red
    end
  end

  def enqueue_sitemaps
    sitemaps.each do |sitemap|
      SitemapIndexerJob.perform_later(sitemap_url: sitemap.loc.to_s)
    end
  end

  def log_info
    {
      time: Time.now.utc.to_formatted_s(:db),
      domain: domain
    }
  end

  def sitemap
    @sitemap ||= HTTP.headers(user_agent: DEFAULT_USER_AGENT).
      timeout(connect: 20, read: 60).follow.get(uri).to_s.freeze
  end

  # Avoid deadlocks while bulk processing URLs in parallel for the same domain
  def skip_counter_callbacks
    SearchgovUrl.skip_callback :create, :after, :_update_counts_after_create
    SearchgovUrl.skip_callback :update, :after, :_update_counts_after_update
  end

  def set_counter_callbacks
    SearchgovUrl.set_callback :create, :after, :_update_counts_after_create
    SearchgovUrl.set_callback :update, :after, :_update_counts_after_update
  end
end
