require 'open-uri'

class SiteAutodiscoverer
  attr_reader :discovered_resources

  FAVICON_LINK_XPATH = "//link[@rel='shortcut icon' or @rel='icon'][@href]".freeze

  def initialize(site, url = nil)
    @site = site
    @autodiscovery_url = url && URI.parse(url).to_s
    @discovered_resources = { 'Favicon URL' => [] }
  end

  def run
    autodiscover_website_contents if autodiscovery_url
  end

  def autodiscover_website(base_url)
    candidate_autodiscovery_urls(base_url).any? do |url|
      response = fetch_and_initialize_website_doc(url)
      update_site_website(response, url) if response[:last_effective_url].present?
    end
  rescue URI::InvalidURIError
    nil
  end

  def update_site_website(response, url)
    website = response[:last_effective_url] == url ? url : response[:last_effective_url]
    @site.update!(website: website) if @site.website != website
    true
  end

  def autodiscover_website_contents
    autodiscover_favicon_url
  end

  def autodiscover_favicon_url
    favicon_url = extract_favicon_url || detect_default_favicon
    if favicon_url.present? && @site.favicon_url != favicon_url
      @site.update!(favicon_url:)
      @discovered_resources['Favicon URL'] << favicon_url
    end
  rescue => e
    Rails.logger.error("Error when autodiscovering favicon for #{@site.name}", e)
  end

  def autodiscovery_url
    @autodiscovery_url ||= begin
      url = @site.default_autodiscovery_url
      autodiscover_website(url)
      url
    end
  end

  def discovered_resources
    @discovered_resources.select { |_title, resources_array| resources_array.present? }
  end

  private

  def website_doc
    @website_doc ||= begin
      fetch_and_initialize_website_doc(autodiscovery_url)
      @website_doc
    end
  end

  def fetch_and_initialize_website_doc(url)
    response = DocumentFetcher.fetch(url)
    @website_doc = Nokogiri::HTML(response[:body]) if response[:body]
    response
  end

  def generate_url(href)
    return nil if href.blank?

    %r{https?://}i.match?(href) ? href : "#{URI.join(website_host_with_scheme, href)}"
  end

  def extract_favicon_url
    website_doc.xpath(FAVICON_LINK_XPATH).
      map { |link_element| generate_url(link_element.attr(:href).to_s.strip) }.
      detect { |favicon_url| favicon_url.present? }
  end

  def detect_default_favicon
    default_favicon_url = "#{website_host_with_scheme}/favicon.ico"
    default_favicon_url unless begin
      Timeout.timeout(10) { open(default_favicon_url) }
    rescue
      nil
    end.nil?
  end

  def website_host_with_scheme
    @website_domain ||= begin
      uri = URI.parse(autodiscovery_url)
      "#{uri.scheme}://#{uri.host}"
    end
  end

  def candidate_autodiscovery_urls(base_url)
    urls = [base_url]
    u = URI.parse(base_url)
    unless /^www\./.match?(u.hostname)
      u.hostname = "www.#{u.hostname}"
      urls << u.to_s
    end
    urls
  end
end
