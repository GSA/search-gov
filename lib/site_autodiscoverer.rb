require 'open-uri'

class SiteAutodiscoverer
  FAVICON_LINK_XPATH = "//link[@rel='shortcut icon' or @rel='icon'][@href]".freeze
  RSS_LINK_XPATH = "//link[@type='application/rss+xml' or @type='application/atom+xml'][@href]".freeze

  def initialize(site)
    @site = site
    @domain = @site.site_domains.pluck(:domain).first
  end

  def run
    autodiscover_website_contents if site_valid_for_autodiscovery?
  end

  def autodiscover_website
    return true if @site.website.present?
    %W(http://#{@domain} http://www.#{@domain}).any? do |url|
      response = fetch_and_initialize_website_doc url
      if response[:last_effective_url].present?
        website = response[:status] =~ /301/ ? response[:last_effective_url] : url
        @site.update_attributes!(website: website)
        true
      else
        false
      end
    end
  end

  def autodiscover_website_contents
    autodiscover_favicon_url
    autodiscover_rss_feeds
    autodiscover_social_media
  end

  def autodiscover_favicon_url
    favicon_url = extract_favicon_url
    favicon_url ||= detect_default_favicon
    @site.update_attributes!(favicon_url: favicon_url) if favicon_url.present?
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
    known_urls = Set.new

    website_doc.xpath('//a/@href').each do |anchor_attr|
      href = anchor_attr.inner_text.squish
      if href =~ %r[\Ahttps?://(www\.)?(flickr|instagram|twitter|youtube)\.com/.+]i
        send("create_#{$2}_profile", href) unless known_urls.include?(href)
        known_urls << href.downcase
      end
    end
  rescue => e
    Rails.logger.error("Error when autodiscovering social media for #{@site.name}: #{e.message}")
  end

  def site_valid_for_autodiscovery?
    @site_valid_for_autodiscovery ||= begin
      @site.website.present? || (@site.site_domains.size == 1 && autodiscover_website)
    end
  end

  private

  def website_doc
    @website_doc ||= begin
      fetch_and_initialize_website_doc @site.website
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
    href =~ %r[https?://]i ? href : "#{URI.join(website_host_with_scheme, href)}"
  end

  def extract_favicon_url
    favicon_url = nil
    website_doc.xpath(FAVICON_LINK_XPATH).each do |link_element|
      favicon_url = generate_url link_element.attr(:href).to_s.strip
      break if favicon_url.present?
    end
    favicon_url
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
      uri = URI.parse(@site.website)
      "#{uri.scheme}://#{uri.host}"
    end
  end

  def create_rss_feed(title, url)
    rss_feed_url = RssFeedUrl.rss_feed_owned_by_affiliate.find_existing_or_initialize url
    return unless rss_feed_url.save

    rss_feed = @site.rss_feeds.build(name: title)
    if rss_feed_url.new_record?
      rss_feed.rss_feed_urls.build(rss_feed_owner_type: 'Affiliate', url: url)
    else
      rss_feed.rss_feed_urls = [rss_feed_url]
    end
    rss_feed.save!
  end

  def create_flickr_profile(url)
    FlickrData.import_profile @site, url
  end

  def create_instagram_profile(url)
    username = extract_profile_name url
    instagram_profile = InstagramData.import_profile username
    return unless instagram_profile

    @site.instagram_profiles << instagram_profile unless @site.instagram_profiles.exists? instagram_profile
  end

  def create_twitter_profile(url)
    screen_name = extract_profile_name(url)
    twitter_profile = TwitterData.import_profile screen_name
    return unless twitter_profile

    unless @site.twitter_profiles.exists? twitter_profile
      @site.affiliate_twitter_settings.create(twitter_profile_id: twitter_profile.id)
    end
  end

  def create_youtube_profile(url)
    username = extract_profile_name url
    youtube_profile = YoutubeData.import_profile username
    return unless youtube_profile

    unless @site.youtube_profiles.exists? youtube_profile
      @site.youtube_profiles << youtube_profile
      @site.enable_video_govbox!
    end
  end

  def extract_profile_name(url)
    url.gsub(/\/$/, '').split('/').last
  end
end
