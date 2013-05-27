module NewsSearchHelper
  DATE_FORMAT = '%b %-d, %Y'.freeze

  def render_current_time_filter(search)
    until_date = search.until ? search.until.to_date : Date.current
    current_label = case
                    when search.tbs.present?
                      I18n.t("last_#{NewsItem::TIME_BASED_SEARCH_OPTIONS[search.tbs]}".to_sym)
                    when search.since.present? && until_date.present? && search.since.to_date == until_date
                      "#{I18n.l(search.since, format: DATE_FORMAT)}"
                    when search.since.present?
                      "#{I18n.l(search.since, format: DATE_FORMAT)} - #{I18n.l(until_date, format: DATE_FORMAT)}"
                    when search.until.present?
                      "#{I18n.t(:before)} #{I18n.l(search.until, format: DATE_FORMAT)}"
                    else
                      I18n.t(:all_time)
                    end
    content_tag(:span, h(current_label), class: 'current-label')
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
