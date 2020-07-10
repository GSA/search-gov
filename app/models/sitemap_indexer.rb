# frozen_string_literal: true

class SitemapIndexer
  attr_reader :domain,
              :scheme,
              :searchgov_domain,
              :uri

  def initialize(sitemap_url:)
    @uri = URI(sitemap_url)
    @domain = uri.host
    @scheme = uri.scheme
    @searchgov_domain = SearchgovDomain.find_by(domain: domain)
  end

  def index
    sitemaps_stream.any? ? enqueue_sitemaps : process_entries
  end

  private

  def sitemaps_stream
    @sitemaps_stream ||= Saxerator.parser(sitemap).
                           within('sitemapindex').for_tag('sitemap')
  end

  def sitemap_entries_stream
    @sitemap_entries_stream ||= Saxerator.parser(sitemap).
                                  within('urlset').for_tag('url')
  end

  def enqueue_sitemaps
    sitemaps_stream.each do |sitemap|
      SitemapIndexerJob.perform_later(sitemap_url: sitemap['loc'].to_s)
    end
  end

  def process_entries
    skip_counter_callbacks
    sitemap_entries_stream.each do |entry|
      process_entry(entry) if entry_matches_domain?(entry)
    end
    searchgov_domain.index_urls
  ensure
    set_counter_callbacks
    update_counter_caches
  end

  def process_entry(entry)
    sitemap_url = UrlParser.update_scheme(entry['loc'].strip, scheme)
    searchgov_url = SearchgovUrl.find_or_initialize_by(url: sitemap_url)
    searchgov_url.update!(lastmod: entry['lastmod'])
  rescue => e
    error_info = log_info.merge(sitemap_entry_failed: sitemap_url, error: e.message)
    log_line = "[Searchgov SitemapIndexer] #{error_info.to_json}"
    Rails.logger.error log_line.red
  end

  def entry_matches_domain?(entry)
    # Eventually we limit the URLS to those
    # strictly adhering to the sitemap protocol,
    # but matching the domain should suffice for now.
    # https://www.pivotaltracker.com/story/show/157485118
    URI(entry['loc'].strip).host == domain
  end

  def log_info
    {
      time: Time.now.utc.to_formatted_s(:db),
      domain: domain,
      sitemap: uri.to_s
    }
  end

  def sitemap
    @sitemap ||= begin
      HTTP.headers(user_agent: DEFAULT_USER_AGENT).
        timeout(connect: 20, read: 60).follow.get(uri).to_s.freeze
    rescue => e
      error_info = log_info.merge(error: e.message)
      log_line = "[Searchgov SitemapIndexer] #{error_info.to_json}"
      Rails.logger.warn log_line.red
      ''
    end
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

  def update_counter_caches
    SearchgovUrl.counter_culture_fix_counts(
      only: :searchgov_domain,
      where: { searchgov_domains: { id: searchgov_domain.id } }
    )
  end
end
