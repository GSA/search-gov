module Analytics::SearchModuleHelper
  def display_most_recent_daily_search_module_stats_date_available(day)
    return "Search module data currently unavailable" if day.nil?
    current_day = content_tag(:span, day.to_s(:long), :class=>"highlight")
    html = "Data for #{current_day}"
    firstdate = DailySearchModuleStat.minimum(:day)
    first = [firstdate.year, (firstdate.month.to_i - 1), firstdate.day].join(',')
    lastdate = DailySearchModuleStat.maximum(:day)
    last = [lastdate.year, (lastdate.month.to_i - 1), lastdate.day].join(',')
    html << calendar_date_select_tag("pop_up_hidden", "", :hidden => true, :image=>"change_date.png", :buttons => false,
                                     :onchange => "location = '#{analytics_search_modules_path}/?day='+$F(this);",
                                     :valid_date_check => "date <= (new Date(#{last})).stripTime() && date >= (new Date(#{first})).stripTime()")
    raw html
  end
end
