module Analytics::HomeHelper
  def affiliate_analytics_weekly_report_links(affiliate, report_date)
    sundays(report_date).collect do |start_of_week|
      link = link_to 'csv', new_site_top_queries_path(affiliate, start_date: start_of_week, end_date: start_of_week + 7.days, format: 'csv')
      "Download top queries for the week of #{start_of_week.to_s} (#{link})".html_safe
    end
  end

  def affiliate_analytics_monthly_report_link(affiliate, report_date)
    link = link_to 'csv', new_site_top_queries_path(affiliate, start_date: report_date.beginning_of_month, end_date: report_date.end_of_month, format: 'csv')
    "Download top queries for #{Date::MONTHNAMES[report_date.month.to_i]} #{report_date.year} (#{link})".html_safe
  end

  def linked_shortened_url_without_protocol(url)
    link_to(url_without_protocol(truncate_url(url)), url)
  end

  private
  def sundays(report_date)
    sundays = [first_sunday(report_date.beginning_of_month)]
    while (sundays.last + 1.week) <= report_date.end_of_month
      sundays << sundays.last + 1.week
    end
    sundays
  end

  def first_sunday(beginning_of_month)
    beginning_of_month + ((7 - beginning_of_month.wday ) % 7).days
  end
end
