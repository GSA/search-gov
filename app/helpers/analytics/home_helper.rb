module Analytics::HomeHelper
  def query_chart_link(query_count)
    html = link_to(query_count.query, make_query_timeline_path(query_count))
    html << " "
    html << link_to(image_tag("open_new_window.png", :alt => "Open graph in new window", :size => "8x8"),
                    make_query_timeline_path(query_count),
                    :popup=>['_blank', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,height=450,width=1000'],
                    :title => "Open graph in new window")
    html
  end

  def display_most_recent_date_available(day, affiliate = nil)
    return "Query data currently unavailable" if day.nil?
    current_day = content_tag(:span,day.to_s(:long), :class=>"highlight")
    html = "Data for #{current_day}"
    firstdate = DailyQueryStat.minimum(:day, :conditions => ['affiliate = ? AND locale = ?', affiliate_name(affiliate), I18n.default_locale.to_s])
    first = [firstdate.year, (firstdate.month.to_i - 1), firstdate.day].join(',')
    lastdate = DailyQueryStat.maximum(:day, :conditions => ['affiliate = ? AND locale = ?', affiliate_name(affiliate), I18n.default_locale.to_s])
    last = [lastdate.year, (lastdate.month.to_i - 1), lastdate.day].join(',')
    html<< calendar_date_select_tag("pop_up_hidden", "", :hidden => true, :image=>"change_date.png", :buttons => false,
                                    :onchange => "location = '#{analytics_path_prefix(affiliate)}/?day='+$F(this);",
                                    :valid_date_check => "date <= (new Date(#{last})).stripTime() && date >= (new Date(#{first})).stripTime()")
  end

  def display_select_for_window(window, num_results, day, affiliate = nil)
    options = [10, 50, 100, 500, 1000].collect{ |x| ["Show #{x} results", x] }
    select_tag("num_results_select#{window}", options_for_select( options, num_results), {
      :onchange => "location = '#{analytics_path_prefix(affiliate)}/?day=#{day}&num_results_#{window}='+this.options[this.selectedIndex].value;"})
  end

  def affiliate_name(affiliate)
    affiliate ? affiliate.name : DailyQueryStat::DEFAULT_AFFILIATE_NAME
  end

  def analytics_path_prefix(affiliate)
    affiliate ? "/affiliates/#{affiliate.id}/analytics" : "/analytics"
  end

  def monthly_report_filename(prefix, report_date)
    "reports/#{prefix}_top_queries_#{report_date.strftime('%Y%m')}.csv"
  end

  def daily_report_filename(prefix, report_date)
    "reports/#{prefix}_top_queries_#{report_date.strftime('%Y%m%d')}.csv"
  end

  def analytics_daily_report_link(report_date)
    if report_date.present?
      english_filename = daily_report_filename(I18n.default_locale.to_s, report_date)
      spanish_filename = daily_report_filename(other_locale_str, report_date)
      english_filename_exists = AWS::S3::S3Object.exists?(english_filename, AWS_BUCKET_NAME)
      spanish_filename_exists = AWS::S3::S3Object.exists?(spanish_filename, AWS_BUCKET_NAME)
      "Download CSV of top 1000 queries for #{ report_date.to_s } (#{ link_to('English', AWS::S3::S3Object.url_for(english_filename, AWS_BUCKET_NAME, :use_ssl => true)) if english_filename_exists }#{ ", " if english_filename_exists && spanish_filename_exists }#{ link_to('Spanish', AWS::S3::S3Object.url_for(spanish_filename, AWS_BUCKET_NAME, :use_ssl => true)) if spanish_filename_exists })" if english_filename_exists || spanish_filename_exists
    end
  end

  def analytics_monthly_report_link(report_date)
    english_filename = monthly_report_filename(I18n.default_locale.to_s, report_date)
    spanish_filename = monthly_report_filename(other_locale_str, report_date)
    english_filename_exists = AWS::S3::S3Object.exists?(english_filename, AWS_BUCKET_NAME)
    spanish_filename_exists = AWS::S3::S3Object.exists?(spanish_filename, AWS_BUCKET_NAME)
    "Download top 20,000 queries for #{Date::MONTHNAMES[report_date.month.to_i]} #{report_date.year} (#{link_to("English", AWS::S3::S3Object.url_for(english_filename, AWS_BUCKET_NAME, :use_ssl => true)) if english_filename_exists }#{ ", " if english_filename_exists && spanish_filename_exists }#{ link_to("Spanish", AWS::S3::S3Object.url_for(spanish_filename, AWS_BUCKET_NAME, :use_ssl => true)) if spanish_filename_exists })" if english_filename_exists || spanish_filename_exists
  end

  def affiliate_analytics_daily_report_link(affiliate_name, report_date)
    if report_date
      filename = daily_report_filename(affiliate_name, report_date)
      "Download top 1000 queries for #{ report_date.to_s } (#{ link_to 'csv', AWS::S3::S3Object.url_for(filename, AWS_BUCKET_NAME, :use_ssl => true) })" if AWS::S3::S3Object.exists?(filename, AWS_BUCKET_NAME)
    end
  end

  def affiliate_analytics_monthly_report_link(affiliate_name, report_date)
    filename = monthly_report_filename(affiliate_name, report_date)
    "Download top queries for #{Date::MONTHNAMES[report_date.month.to_i]} #{report_date.year} (#{link_to 'csv', AWS::S3::S3Object.url_for(filename, AWS_BUCKET_NAME, :use_ssl => true)}" if AWS::S3::S3Object.exists?(filename, AWS_BUCKET_NAME)
  end

  private
  def make_query_timeline_path(query_count)
    query_count.is_grouped? ?  query_timeline_path(query_count.query, :grouped => 1) : query_timeline_path(query_count.query)
  end
end