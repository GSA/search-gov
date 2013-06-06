module Analytics::HomeHelper
  def base_query_chart_link(query, path_for_query_timeline)
    html = link_to(query, path_for_query_timeline)
    html << " "
    html << link_to(image_tag('legacy/open_new_window.png', :alt => "Open graph in new window", :size => "8x8"),
                    path_for_query_timeline,
                    :class => 'analytics-timeline-popup',
                    :title => "Open graph in new window")
    html
  end

  def affiliate_query_chart_link(query, affiliate)
    base_query_chart_link(query, affiliate_query_timeline_path(affiliate, query))
  end

  def affiliate_query_clicks_link(query, affiliate, start_date, end_date)
    title = "View top clicked URLs for this query term"
    link = query_clicks_affiliate_analytics_path(affiliate, {:query => query, :start_date => start_date, :end_date => end_date})
    link_to(image_tag('legacy/table_link.png', :alt => title, :size => "8x8"), link, :title => title)
  end

  def affiliate_click_queries_link(url, affiliate, start_date, end_date)
    title = "View top query terms leading to this URL"
    link = click_queries_affiliate_analytics_path(affiliate, {:url => url, :start_date => start_date, :end_date => end_date})
    link_to(image_tag('legacy/table_link.png', :alt => title, :size => "8x8"), link, :title => title)
  end

  def date_in_javascript_format(day)
    [day.year, (day.month.to_i - 1), day.day].join(',')
  end

  def monthly_report_filename(prefix, report_date)
    "analytics/reports/#{prefix}/#{prefix}_top_queries_#{report_date.strftime('%Y%m')}.csv"
  end

  def weekly_report_filename(prefix, report_date)
    "analytics/reports/#{prefix}/#{prefix}_top_queries_#{report_date.strftime('%Y%m%d')}_weekly.csv"
  end

  def daily_report_filename(prefix, report_date)
    "analytics/reports/#{prefix}/#{prefix}_top_queries_#{report_date.strftime('%Y%m%d')}.csv"
  end

  def affiliate_analytics_daily_report_link(affiliate_name, report_date)
    if report_date
      filename = daily_report_filename(affiliate_name.downcase, report_date)
      "Download top queries for #{ report_date.to_s } (#{ link_to 'csv', s3_link(filename) })".html_safe if AWS::S3::S3Object.exists?(filename, AWS_BUCKET_NAME)
    end
  end

  def affiliate_analytics_weekly_report_links(affiliate_name, report_date)
    starts_of_weeks = [report_date.beginning_of_month.wday == 0 ? report_date.beginning_of_month : report_date.beginning_of_month + (7 - report_date.beginning_of_month.wday).days]
    while (starts_of_weeks.last + 7.days) <= report_date.end_of_month
      starts_of_weeks << starts_of_weeks.last + 7.days
    end
    report_links = starts_of_weeks.collect do |start_of_week|
      filename = weekly_report_filename(affiliate_name.downcase, start_of_week)
      "Download top queries for the week of #{start_of_week.to_s} (#{link_to 'csv', s3_link(filename)})".html_safe if AWS::S3::S3Object.exists?(filename, AWS_BUCKET_NAME)
    end
    report_links.compact
  end

  def affiliate_analytics_monthly_report_link(affiliate_name, report_date)
    filename = monthly_report_filename(affiliate_name.downcase, report_date)
    "Download top queries for #{Date::MONTHNAMES[report_date.month.to_i]} #{report_date.year} (#{link_to 'csv', s3_link(filename)})".html_safe if AWS::S3::S3Object.exists?(filename, AWS_BUCKET_NAME)
  end

  def display_select_for_date_range_window(window, num_results, start_day, end_day, location_path)
    display_select_for_window("num_results_select#{window}", num_results, {:onchange => "location = '#{location_path}/?start_date=#{start_day}&end_date=#{end_day}&num_results_#{window}='+this.options[this.selectedIndex].value;"})
  end

  def twitter_query_link(query)
    title = "Twitter search results"
    link = "http://twitter.com/search/#{query}"
    link_to(image_tag('legacy/govbox/twitter.png', :alt => title), link, :title => title)
  end

  def google_news_query_link(query)
    title = "Google news results"
    link = "https://news.google.com/news/search?q=#{query}"
    link_to(image_tag('legacy/google_news.png', :alt => title), link, :title => title)
  end

  def google_trends_query_link(query)
    title = "Google trends"
    link = "https://www.google.com/trends/explore#q=#{query}"
    link_to(image_tag('legacy/google_trends.png', :alt => title), link, :title => title)
  end

  private

  def display_select_for_window(tag_name, num_results, options_hash)
    options = [10, 50, 100, 500, 1000].collect { |x| ["Show #{x} results", x] }
    select_tag(tag_name, options_for_select(options, num_results), options_hash)
  end

  def s3_link(filename)
    AWS::S3::S3Object.url_for(filename, AWS_BUCKET_NAME, :use_ssl => true)
  end
end
