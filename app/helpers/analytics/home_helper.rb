module Analytics::HomeHelper
  def rtu_affiliate_analytics_weekly_report_links(affiliate, report_date)
    start_of_weeks(report_date).select { |date| date <= Date.current }.map do |start_of_week|
      params = { start_date: start_of_week, end_date: start_of_week + 6.days, format: 'csv' }
      "Download top queries for the week of #{start_of_week.to_s} (#{link_to 'csv', site_query_downloads_path(affiliate, params)})".html_safe
    end
  end

  def start_of_weeks(report_date)
    starts_of_weeks = [report_date.beginning_of_month.wday == 0 ? report_date.beginning_of_month : report_date.beginning_of_month + (7 - report_date.beginning_of_month.wday).days]
    while (starts_of_weeks.last + 7.days) <= report_date.end_of_month
      starts_of_weeks << starts_of_weeks.last + 7.days
    end
    starts_of_weeks
  end

  def rtu_affiliate_analytics_monthly_report_link(affiliate, report_date)
    params = { start_date: report_date.beginning_of_month, end_date: report_date.end_of_month, format: 'csv' }
    "Download top queries for #{Date::MONTHNAMES[report_date.month.to_i]} #{report_date.year} (#{link_to 'csv', site_query_downloads_path(affiliate, params)})".html_safe
  end

  def linked_shortened_url_without_protocol(url)
    link_to(url_without_protocol(truncate_url(url)), url)
  end

end
