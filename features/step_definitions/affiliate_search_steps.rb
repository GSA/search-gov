Given /^affiliate "([^"]*)" has the following RSS feeds:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    rss_feed_url = RssFeedUrl.where(rss_feed_owner_type: 'Affiliate',
                                    url: hash[:url]).first_or_initialize
    rss_feed_url.assign_attributes(last_crawled_at: hash[:last_crawled_at],
                                   last_crawl_status: hash[:last_crawl_status] || RssFeedUrl::PENDING_STATUS,
                                   oasis_mrss_name: hash[:oasis_mrss_name])
    rss_feed_url.save!(validate: false)

    is_managed = hash[:is_managed].blank? ? false : hash[:is_managed]
    show_only_media_content = hash[:show_only_media_content].blank? ? false : hash[:show_only_media_content]

    if is_managed
      rss_feed = affiliate.rss_feeds.where(is_managed: true).first_or_initialize
      rss_feed.update!(name: hash[:name],
                                  show_only_media_content: show_only_media_content,
                                  rss_feed_urls: [rss_feed_url])
    else
      rss_feed = affiliate.rss_feeds.create!(name: hash[:name],
                                             is_managed: is_managed,
                                             show_only_media_content: show_only_media_content,
                                             rss_feed_urls: [rss_feed_url])
    end
    rss_feed.navigation.update!(is_active: hash[:is_navigable] || false,
                                           position: hash[:position] || 100)
  end
  NewsItem.destroy_all
end

Given /^feed "([^"]*)" has the following news items:$/ do |feed_name, table|
  rss_feed = RssFeed.find_by_name feed_name
  rss_feed_url = rss_feed.rss_feed_urls.first
  table.hashes.each do |hash|

    non_attribute_keys = %w(content_url multiplier published_ago published_at thumbnail_url)
    attributes = hash.except *non_attribute_keys

    published_at = hash[:published_at].present? ? hash[:published_at] : nil
    multiplier = (hash[:multiplier] || '1').to_i
    published_at ||= hash[:published_ago].blank? ? 1.day.ago : multiplier.send(hash[:published_ago]).ago
    attributes['published_at'] = published_at
    attributes['guid'] = hash[:guid] || SecureRandom.hex(8)

    properties = {}
    properties[:media_content] = { url: hash[:content_url] } if hash[:content_url].present?
    properties[:media_thumbnail] = { url: hash[:thumbnail_url] } if hash[:thumbnail_url].present?
    attributes['properties'] = properties

    rss_feed_url.news_items.create! attributes
  end
  ElasticNewsItem.commit
end

Given /^there are (\d+)( image| video)? news items for "([^"]*)"$/ do |count, is_image_or_video, feed_name|
  rss_feed = RssFeed.find_by_name "#{feed_name}"
  rss_feed_url = rss_feed.rss_feed_urls.first
  now = Time.current.to_i
  published_at = 1.week.ago
  count.to_i.times do |index|
    content_prefix = ''
    properties = {}

    case is_image_or_video
      when /image/
        link = "http://www.usgs.gov/image_#{index + 1}"
        properties[:media_content] = { url: "#{link}.jpg" }
        properties[:media_thumbnail] = { url: "#{link}_q.jpg" }
        content_prefix = 'image'
      when /video/
        link_param = { v: "#{index}_#{feed_name}" }
        link = "http://www.youtube.com/watch?#{link_param.to_query}"
        content_prefix = 'video'
      else
        link = "http://aff.gov/#{now}_#{index + 1}"
    end
    rss_feed_url.news_items.create!(:link => link,
                                    :title => "#{content_prefix} news item #{index + 1} title for #{feed_name}",
                                    :description => "#{content_prefix} news item #{index + 1} description for #{feed_name}",
                                    :body => "#{content_prefix} news item #{index + 1} body for #{feed_name}",
                                    :guid => "#{now}_#{index + 1}_#{feed_name}",
                                    :published_at => published_at - index,
                                    :properties => properties)
  end
  ElasticNewsItem.commit
end

Given /^there are (\d+)( manual| rss)? indexed documents for affiliate "([^"]*)"$/ do |count, source, affiliate|
  affiliate = Affiliate.find_by(name: affiliate)

  count.to_i.times do |index|
    IndexedDocument.create!(affiliate: affiliate,
                            title: "Document number #{index + 1}",
                            description: 'An Indexed Document',
                            url: "http://petitions.whitehouse.gov/petition-#{index + 1}.html",
                            source: source.strip,
                            last_crawl_status: 'OK',
                            last_crawled_at: Time.current.to_i)
  end
  ElasticIndexedDocument.commit
end

Then /^I should not see "([^"]*)" in bold font$/ do |text|
  page.should_not have_selector("strong", :text => text)
end

Then /^I should see "([^"]*)" in bold font$/ do |text|
  page.should have_selector("strong", :text => text)
end

Given /^the following Medline Topics exist:$/ do |table|
  table.hashes.each { |hash| MedTopic.create! hash }
end

Given /^the following Related Medline Topics for "([^"]*)" in (English|Spanish) exist:$/ do |medline_title, language, table|
  locale = language == 'English' ? 'en' : 'es'
  topic = MedTopic.where(:medline_title => medline_title, :locale => locale).first
  table.hashes.each do |hash|
    topic.med_related_topics.create!(:related_medline_tid => hash[:medline_tid],
                                     :title => hash[:medline_title],
                                     :url => hash[:url])
  end
end

Then /^I should see (\d+) search result title links? with url for "([^"]*)"$/ do |count, url|
  page.should have_selector(".title a[href='#{url}']", count: count)
end

Then /^I should see a link to "([^"]*)" with text "([^"]*)"$/ do |url, text|
  page.should have_link(text, :href => url)
end
