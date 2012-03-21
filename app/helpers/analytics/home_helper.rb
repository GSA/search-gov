module Analytics::HomeHelper
  def base_query_chart_link(query, path_for_query_timeline)
    html = link_to(query, path_for_query_timeline)
    html << " "
    html << link_to(image_tag("open_new_window.png", :alt => "Open graph in new window", :size => "8x8"),
                    path_for_query_timeline,
                    :class => 'analytics-timeline-popup',
                    :title => "Open graph in new window")
    html
  end

  def affiliate_query_chart_link(query, affiliate)
    base_query_chart_link(query, affiliate_query_timeline_path(affiliate, query))
  end

  def date_in_javascript_format(day)
    [day.year, (day.month.to_i - 1), day.day].join(',')
  end

  def analytics_path_prefix(affiliate)
    "/affiliates/#{affiliate.id}/analytics"
  end

  def monthly_report_filename(prefix, report_date)
    "analytics/reports/#{prefix}/#{prefix}_top_queries_#{report_date.strftime('%Y%m')}.csv"
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

  def affiliate_analytics_monthly_report_link(affiliate_name, report_date)
    filename = monthly_report_filename(affiliate_name.downcase, report_date)
    "Download top queries for #{Date::MONTHNAMES[report_date.month.to_i]} #{report_date.year} (#{link_to 'csv', s3_link(filename)})".html_safe if AWS::S3::S3Object.exists?(filename, AWS_BUCKET_NAME)
  end

  def display_select_for_date_range_window(window, num_results, start_day, end_day, affiliate = nil)
    display_select_for_window("num_results_select#{window}", num_results, {:onchange => "location = '#{analytics_path_prefix(affiliate)}/?start_date=#{start_day}&end_date=#{end_day}&num_results_#{window}='+this.options[this.selectedIndex].value;"})
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
