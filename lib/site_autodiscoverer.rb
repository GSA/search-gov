require 'open-uri'

class SiteAutodiscoverer
  attr_reader :discovered_resources

  FAVICON_LINK_XPATH = "//link[@rel='shortcut icon' or @rel='icon'][@href]".freeze
  RSS_LINK_XPATH = "//link[@type='application/rss+xml' or @type='application/atom+xml'][@href]".freeze
  SOCIAL_MEDIA_REGEXP = %r{\Ahttps?://(www\.)?(flickr|twitter|youtube)\.com/.+}i

  def initialize(site, url = nil)
    @site = site
    @autodiscovery_url = url && URI.parse(url).to_s
    @discovered_resources = { 'Favicon URL' => [], 'RSS Feeds' => [], 'Social Media' => [] }
  end

  def run
    autodiscover_website_contents if autodiscovery_url
  end

  def autodiscover_website(base_url)
    candidate_autodiscovery_urls(base_url).any? do |url|
      response = fetch_and_initialize_website_doc url
      update_site_website(response, url) if response[:last_effective_url].present?
    end
  rescue URI::InvalidURIError
    nil
  end

  def update_site_website(response, url)
    website = response[:last_effective_url] != url ? response[:last_effective_url] : url
    @site.update!(website: website) if @site.website != website
    true
  end

  def autodiscover_website_contents
    autodiscover_favicon_url
    autodiscover_rss_feeds
    autodiscover_social_media
  end

  def autodiscover_favicon_url
    favicon_url = extract_favicon_url
    favicon_url ||= detect_default_favicon
    if favicon_url.present? && @site.favicon_url != favicon_url
      @site.update!(favicon_url: favicon_url)
      @discovered_resources['Favicon URL'] << favicon_url
    end
  rescue => e
    Rails.logger.error("Error when autodiscovering favicon for #{@site.name}: #{e.message}")
  end

  def autodiscover_rss_feeds
    website_doc.xpath(RSS_LINK_XPATH).each do |link_element|
      create_rss_feed *extract_title_and_valid_url_from_rss_feed_link(link_element)
    end
  rescue => e
    Rails.logger.error("Error when autodiscovering rss feeds for #{@site.name}: #{e.message}")
  end

  def autodiscover_social_media
    website_doc.xpath('//a/@href').
      map { |anchor_attr| anchor_attr.inner_text.squish.downcase }.
      uniq.
      each { |href| create_social_media_profile(href) }
  rescue => e
    Rails.logger.error("Error when autodiscovering social media for #{@site.name}: #{e.message}")
  end

  def create_social_media_profile(href)
    SOCIAL_MEDIA_REGEXP.match(href) { |match_data| send("create_#{match_data[2]}_profile", href) }
  end

  def autodiscovery_url
    @autodiscovery_url ||= begin
      url = @site.default_autodiscovery_url
      autodiscover_website(url)
      url
    end
  end

  def discovered_resources
    @discovered_resources.select { |title, resources_array| resources_array.present? }
  end

  private

  def website_doc
    @website_doc ||= begin
      fetch_and_initialize_website_doc autodiscovery_url
      @website_doc
    end
  end

  def fetch_and_initialize_website_doc(url)
    response = DocumentFetcher.fetch url
    @website_doc = Nokogiri::HTML response[:body] if response[:body]
    response
  end

  def generate_url(href)
    return nil if href.blank?
    href =~ %r{https?://}i ? href : "#{URI.join(website_host_with_scheme, href)}"
  end

  def extract_favicon_url
    website_doc.xpath(FAVICON_LINK_XPATH).
      map { |link_element| generate_url link_element.attr(:href).to_s.strip }.
      detect { |favicon_url| favicon_url.present? }
  end

  def detect_default_favicon
    default_favicon_url = "#{website_host_with_scheme}/favicon.ico"
    default_favicon_url unless (timeout(10) { open(default_favicon_url) } rescue nil).nil?
  end

  def extract_title_and_valid_url_from_rss_feed_link(link_element)
    url = generate_url link_element.attr(:href).to_s.strip
    title = link_element.attr(:title).to_s.squish
    title = url unless title.present?
    [title, url]
  end

  def website_host_with_scheme
    @website_domain ||= begin
      uri = URI.parse(autodiscovery_url)
      "#{uri.scheme}://#{uri.host}"
    end
  end

  def create_rss_feed(title, url)
    rss_feed_url = RssFeedUrl.rss_feed_owned_by_affiliate.find_existing_or_initialize url
    return unless rss_feed_url.save

    rss_feed = @site.rss_feeds.find_existing_or_initialize(title, url)
    if rss_feed.new_record?
      @site.rss_feeds << rss_feed
      @discovered_resources['RSS Feeds'] << url
    end

    if rss_feed_url.new_record?
      rss_feed.rss_feed_urls.build(rss_feed_owner_type: 'Affiliate', url: url)
    else
      rss_feed.rss_feed_urls = [rss_feed_url]
    end
    rss_feed.save!
  end

  def create_flickr_profile(url)
    flickr_data = FlickrData.new @site, url
    flickr_data.import_profile
    @discovered_resources['Social Media'] << url if flickr_data.new_profile_created?
  end

  def create_twitter_profile(url)
    screen_name = extract_profile_name(url)
    twitter_profile = TwitterData.import_profile screen_name
    return unless twitter_profile

    unless @site.twitter_profiles.exists?(id: twitter_profile.id)
      @site.affiliate_twitter_settings.create(twitter_profile_id: twitter_profile.id)
      @discovered_resources['Social Media'] << url
    end
  end

  def create_youtube_profile(url)
    youtube_profile = YoutubeProfileData.import_profile url
    return unless youtube_profile

    unless @site.youtube_profiles.exists?(id: youtube_profile.id)
      @site.youtube_profiles << youtube_profile
      @discovered_resources['Social Media'] << url
      @site.enable_video_govbox!
    end
  end

  def extract_profile_name(url)
    url.gsub(/(\/|\?.*)$/, '').split('/').last
  end

  def candidate_autodiscovery_urls(base_url)
    urls = [base_url]
    u = URI.parse(base_url)
    unless u.hostname =~ /^www\./
      u.hostname = "www.#{u.hostname}"
      urls << u.to_s
    end
    urls
  end
end
