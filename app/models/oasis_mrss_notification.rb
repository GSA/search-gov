class OasisMrssNotification
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.perform(rss_feed_url_id)
    rss_feed_url = RssFeedUrl.find rss_feed_url_id
    return "URL does not look like an image URL" if rss_feed_url.url =~ /video|podcast|youtube|audio|vodcast|flickr|mp4/i
    rss_doc = Nokogiri::XML(HttpConnection.get(rss_feed_url.url))
    return "XML root is not RSS" if rss_doc.root.name != 'rss'
    return "Missing MRSS namespace" unless rss_doc.namespaces.values.include? 'http://search.yahoo.com/mrss/'
    return "Missing media thumbnails" if rss_doc.xpath("//item/media:thumbnail").empty?
    mrss_profile_json = Oasis.subscribe_to_mrss(rss_feed_url.url)
    rss_feed_url.update_attribute(:oasis_mrss_name, mrss_profile_json['name'])
  rescue Exception => e
    Rails.logger.warn("Trouble linking up MRSS feed to Oasis: #{e}")
  end

end
