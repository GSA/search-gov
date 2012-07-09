class RssFeedUrl < ActiveRecord::Base
  include ActiveRecordExtension
  OK_STATUS = 'OK'
  PENDING_STATUS = 'Pending'
  STATUSES = [OK_STATUS, PENDING_STATUS]
  RSS_ELEMENTS = { :item => 'item',
                   :pubDate => %w(pubDate),
                   :link => %w(link),
                   :title => 'title',
                   :guid => 'guid',
                   :description => 'description' }

  ATOM_ELEMENTS = { :item => 'xmlns:entry',
                    :pubDate => %w(xmlns:published xmlns:updated),
                    :link => %w(xmlns:link[@rel='alternate'][@href]/@href xmlns:link/@href),
                    :title => 'xmlns:title',
                    :guid => 'xmlns:id',
                    :description => 'xmlns:content' }

  FEED_ELEMENTS = { :rss => RSS_ELEMENTS, :atom => ATOM_ELEMENTS }

  PLAYLIST_RSS_ELEMENTS = RSS_ELEMENTS.merge(
      { :pubDate => %w(media:group/yt:uploaded),
        :description => 'media:group/media:description' })

  MAX_YOUTUBE_RESULTS = 1000

  belongs_to :rss_feed
  has_many :news_items, :order => "published_at DESC", :dependent => :destroy
  validates_presence_of :url
  validate :url_must_point_to_a_feed

  def is_video?
    url =~ /^https?:\/\/gdata\.youtube\.com\/feeds\/.+$/i
  end

  def is_playlist?
    url =~ /^https?:\/\/gdata\.youtube\.com\/feeds\/api\/playlists\/.+$/i
  end

  def freshen(ignore_older_items = true)
    touch(:last_crawled_at)
    begin
      most_recently = !is_managed_playlist? && !is_last_crawl_status_pending? && news_items.present? ? news_items.first.published_at : nil
      rss_document = Nokogiri::XML(Kernel.open(url))
      feed_type = detect_feed_type(rss_document)
      if feed_type.nil?
        update_attributes!(:last_crawl_status => "Unknown feed type.")
      else
        extract_counter = (is_managed_video? && is_last_crawl_status_pending? or is_managed_playlist?) ? (total_video_count_in_document(rss_document)/max_video_results_per_pull).ceil - 1 : 0
        feed_elements = is_managed_playlist? ? PLAYLIST_RSS_ELEMENTS : FEED_ELEMENTS[feed_type]
        extract_news_items(rss_document, feed_elements, most_recently, ignore_older_items, extract_counter)
        news_items.where('updated_at < ?', updated_at).destroy_all if is_managed_playlist?
        update_attributes!(:last_crawl_status => OK_STATUS)
      end
    rescue Exception => e
      update_attributes!(:last_crawl_status => e.message)
      Rails.logger.warn(e)
    end
  end

  def is_managed_video?
    rss_feed.is_managed? and is_video?
  end

  def is_managed_playlist?
    rss_feed.is_managed? and is_playlist?
  end

  def is_last_crawl_status_pending?
    last_crawl_status == PENDING_STATUS
  end

  private

  def url_must_point_to_a_feed
    return unless changed.include?('url')
    set_http_prefix :url
    if url =~ /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
      begin
        rss_doc = Nokogiri::XML(Kernel.open(url))
        errors.add(:url, "does not appear to be a valid RSS feed.") if detect_feed_type(rss_doc).nil?
      rescue Exception => e
        errors.add(:url, "does not appear to be a valid RSS feed. Additional information: " + e.message)
      end
    else
      errors.add(:url, "is invalid")
    end
  end

  def detect_feed_type(document)
    case document.root.name
      when 'feed' then :atom
      when 'rss' then :rss
      else nil
    end
  end

  def extract_news_items(document, feed_elements, most_recently, ignore_older_items, extract_counter)
    return unless document
    document.xpath("//#{feed_elements[:item]}").each do |item|
      published_at = nil
      feed_elements[:pubDate].each do |pub_date_path|
        published_at_str = item.xpath(pub_date_path).inner_text
        next if published_at_str.blank?
        published_at = DateTime.parse published_at_str
        break if published_at.present?
      end

      break if most_recently and published_at < most_recently and ignore_older_items

      link = ''
      feed_elements[:link].each do |link_path|
        link = item.xpath(link_path).inner_text
        break if link.present?
      end

      title = item.xpath(feed_elements[:title]).inner_text
      guid = item.xpath(feed_elements[:guid]).inner_text
      guid = link if guid.blank?
      raw_description = item.xpath(feed_elements[:description]).inner_text
      description = Nokogiri::HTML(raw_description).inner_text.squish

      duplicate = rss_feed.news_items.first(:conditions => ['guid = ? OR link = ?', guid, link])
      if duplicate
        duplicate.touch if is_playlist?
      else
        news_items.create!(:rss_feed => rss_feed,
                           :link => link,
                           :title => title,
                           :description => description,
                           :published_at => published_at,
                           :guid => guid)
      end
    end

    if extract_counter > 0
      extract_news_items next_videos_document(document), feed_elements, most_recently, ignore_older_items, extract_counter - 1
    end
  end

  def total_video_count_in_document(document)
    document.xpath('/rss/channel/openSearch:totalResults').inner_text.to_f
  end

  def next_videos_document(document)
    next_url = next_videos_url(document)
    return if next_url.nil?
    Nokogiri::XML(Kernel.open(next_url))
  end

  def next_videos_url(document)
    next_start_index = video_start_index(document) + max_video_results_per_pull
    return if next_start_index > MAX_YOUTUBE_RESULTS
    if is_playlist?
      url.sub("&start-index=1&", "&start-index=#{next_start_index}&")
    else
      query_params = CGI.parse(URI.parse(url).query)
      url_params = { :alt => 'rss',
                     :author => query_params['author'].first,
                     :'max-results' => max_video_results_per_pull,
                     :orderby => 'published',
                     :'start-index' => next_start_index }
      "http://gdata.youtube.com/feeds/base/videos?#{url_params.to_param}"
    end
  end

  def video_start_index(document)
    document.xpath('/rss/channel/openSearch:startIndex').inner_text.to_i
  end

  def max_video_results_per_pull
    is_playlist? ? 50 : 25
  end
end
