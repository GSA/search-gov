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
      doc = open(url) rescue nil
      if doc
        @site.update_attributes!(website: url)
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
    return unless site_valid_for_autodiscovery?
    begin
      favicon_url = nil
      website_doc.xpath(FAVICON_LINK_XPATH).each do |link_element|
        favicon_url = generate_url link_element.attr(:href).to_s.strip
        break if favicon_url.present?
      end

      favicon_url ||= detect_default_favicon

      @site.update_attributes!(favicon_url: favicon_url) if favicon_url.present?
    rescue Exception => e
      Rails.logger.error("Error when autodiscovering favicon for #{@site.name}: #{e.message}")
    end
  end

  def autodiscover_rss_feeds
    return unless site_valid_for_autodiscovery?
    begin
      website_doc.xpath(RSS_LINK_XPATH).each do |link_element|
        url = generate_url link_element.attr(:href).to_s.strip
        title = link_element.attr(:title).to_s.squish
        title = url unless title.present?
        create_rss_feed title, url
      end
    rescue Exception => e
      Rails.logger.error("Error when autodiscovering rss feeds for #{@site.name}: #{e.message}")
    end
  end

  def autodiscover_social_media
    return unless site_valid_for_autodiscovery?
    begin
      website_doc.xpath('//a[@href]').each do |anchor_element|
        href = anchor_element.attr(:href).to_s.squish
        if href =~ %r[https?://(www\.)?(flickr|twitter|youtube)\.com/.+]i
          send "create_#{$2}_profile", href
        end
      end
    rescue Exception => e
      Rails.logger.error("Error when autodiscovering social media for #{@site.name}: #{e.message}")
    end
  end

  def site_valid_for_autodiscovery?
    @site_valid_for_autodiscovery ||= begin
      @site.website.present? || (@site.site_domains.size == 1 && autodiscover_website)
    end
  end

  private

  def website_doc
    @website_doc ||= Nokogiri::HTML(open @site.website)
  end

  def generate_url(href)
    return nil if href.blank?
    href =~ %r[https?://]i ? href : "#{website_host_with_scheme}#{href}"
  end

  def detect_default_favicon
    default_favicon_url = "#{website_host_with_scheme}/favicon.ico"
    default_favicon_url unless (timeout(10) { open(default_favicon_url) } rescue nil).nil?
  end

  def website_host_with_scheme
    @website_domain ||= begin
      uri = URI.parse(@site.website)
      "#{uri.scheme}://#{uri.host}"
    end
  end

  def create_rss_feed(title, url)
    rss_feed_url = RssFeedUrl.rss_feed_owned_by_affiliate.find_existing_or_initialize url
    rss_feed = @site.rss_feeds.build(name: title)
    if rss_feed_url.new_record?
      rss_feed.rss_feed_urls.build(rss_feed_owner_type: 'Affiliate', url: url)
    else
      rss_feed.rss_feed_urls = [rss_feed_url]
    end
    rss_feed.save
  end

  def create_flickr_profile(url)
    @site.flickr_profiles.create(url: url)
  end

  def create_twitter_profile(url)
    screen_name = extract_profile_name(url)
    twitter_user = Twitter.user(screen_name) rescue nil
    return unless twitter_user

    twitter_profile = TwitterProfile.find_and_update_or_create! twitter_user

    unless @site.twitter_profiles.exists?(twitter_profile.id)
      @site.affiliate_twitter_settings.create(twitter_profile: twitter_profile)
    end
  end

  def create_youtube_profile(url)
    username = extract_profile_name(url)
    youtube_profile = YoutubeProfile.where(username: username).first_or_initialize
    if !youtube_profile.new_record? || youtube_profile.save
      @site.youtube_profiles << youtube_profile
      @site.enable_video_govbox!
    end
  end

  def extract_profile_name(url)
    url.gsub(/\/$/, '').split('/').last
  end
end
