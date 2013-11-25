module Analytics::HomeHelper
  def monthly_report_filename(prefix, report_date)
    "analytics/reports/#{prefix}/#{prefix}_top_queries_#{report_date.strftime('%Y%m')}.csv"
  end

  def weekly_report_filename(prefix, report_date)
    "analytics/reports/#{prefix}/#{prefix}_top_queries_#{report_date.strftime('%Y%m%d')}_weekly.csv"
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

  def linked_shortened_url_without_protocol(url)
    link_to(url_without_protocol(truncate_url(url)), url)
  end

  private

  def s3_link(filename)
    AWS::S3::S3Object.url_for(filename, AWS_BUCKET_NAME, :use_ssl => true)
  end
end
