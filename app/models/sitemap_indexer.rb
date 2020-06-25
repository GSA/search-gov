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
    enqueue_sitemaps
    process_entries
  end

  private

  def enqueue_sitemaps
    Saxerator.parser(sitemap).within('sitemapindex').for_tag('sitemap').each do |sitemap|
      SitemapIndexerJob.perform_later(sitemap_url: sitemap['loc'].to_s)
    end
  end

  def process_entries
    skip_counter_callbacks
    count = 0
    Saxerator.parser(sitemap).within('urlset').for_tag('url').each do |entry|
      if URI(entry['loc'].strip).host == domain
        process_entry(entry)
        count += 1
      end
    end
    line = '[Searchgov SitemapIndexer] '\
           "#{log_info.merge(sitemap_entries_found: count).to_json}"
    Rails.logger.info line
    searchgov_domain.index_urls
  ensure
    set_counter_callbacks
    update_counter_caches
  end

  def process_entry(entry)
    begin
      sitemap_url = UrlParser.update_scheme(entry['loc'].strip, scheme)
      searchgov_url = SearchgovUrl.find_or_initialize_by(url: sitemap_url)
      searchgov_url.update!(lastmod: entry['lastmod'])
    rescue => e
      line = '[Searchgov SitemapIndexer] '\
             "#{log_info.merge(sitemap_entry_failed: sitemap_url,
                               error: e.message).to_json}"
      Rails.logger.error line.red
    end
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
      line = "[Searchgov SitemapIndexer] #{log_info.merge(error: e.message).to_json}"
      Rails.logger.warn line.red
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
