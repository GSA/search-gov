module NewsSearchHelper
  DATE_FORMAT = '%b %-d, %Y'.freeze

  def current_time_filter_description(search)
    until_date = search.until ? search.until.to_date : Date.current

    case
    when search.tbs
      I18n.t "last_#{FilterableSearch::TIME_BASED_SEARCH_OPTIONS[search.tbs]}"
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
end
