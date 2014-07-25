module NewsSearchHelper
  DATE_FORMAT = '%b %-d, %Y'.freeze

  def render_current_time_filter(search)
    current_label = current_time_filter_description search
    content_tag(:span, h(current_label), class: 'current-label')
  end

  def current_time_filter_description(search)
    until_date = search.until ? search.until.to_date : Date.current

    case
    when search.tbs
      I18n.t "last_#{NewsItem::TIME_BASED_SEARCH_OPTIONS[search.tbs]}"
    when search.since
      desc = localized_time_filter_date search.since
      desc << " - #{localized_time_filter_date until_date}" unless search.since.to_date == until_date
      desc
    when search.until
      "#{I18n.t :before} #{localized_time_filter_date search.until}"
    else
      I18n.t :all_time
    end
  end

  def localized_time_filter_date(date, format = DATE_FORMAT)
    I18n.l date, format: format
  end

  def render_current_sort_filter(sort_by)
    current_label = sort_by == 'r' ? I18n.t(:by_relevance) : I18n.t(:by_date)
    content_tag(:span, h(current_label), class: 'current-label')
  end

  def determine_feed_type(rss_feed)
    if rss_feed && rss_feed.is_managed?
      'videos'
    elsif rss_feed and rss_feed.show_only_media_content?
      'media'
    else
      'text'
    end
  end

  def determine_news_item_partial(feed_type)
    case feed_type
    when 'text' then 'shared/news_item'
    when 'videos' then 'shared/video_news_item'
    when 'media' then 'shared/image_news_item'
    end
  end

end
