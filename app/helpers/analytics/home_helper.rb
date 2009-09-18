module Analytics::HomeHelper
  def display_most_popular(pairs)
    html = content_tag(:h3, "Most Popular")
    if pairs
      rows = ""
      count = 1
      pairs.each_pair do |query, times|
        query_link = link_to(query, query_timeline_path(query))
        popup_query_link = link_to(image_tag("open_new_window.png", :alt => "Open chart in new window", :size => "8x8"), query_timeline_path(query), :popup=>['_blank', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,height=450,width=1000'])
        cells = content_tag(:td, "#{count}. #{query_link} #{popup_query_link}", :style=>"text-align:left")
        cells << content_tag(:td, times, :style=>"text-align:right")
        rows << content_tag(:tr, cells)
        count += 1
      end
      html << content_tag(:table, rows)
    else
      html << content_tag(:p, "Query data unavailable", :class=>"alt")
    end

    html
  end

  def display_biggest_movers(query_accelerations)
    html = content_tag(:h3, "Biggest Movers")
    if query_accelerations
      rows = ""
      query_accelerations.each_with_index do |qa, count|
        query_link = link_to(qa.query, query_timeline_path(qa.query))
        popup_query_link = link_to(image_tag("open_new_window.png", :alt => "Open chart in new window", :size => "8x8"), query_timeline_path(qa.query), :popup=>['_blank', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,height=450,width=1000'])
        cells = content_tag(:td, "#{count+1}. #{query_link} #{popup_query_link}", :style=>"text-align:left")
        cells << content_tag(:td, qa.sum_times, :style=>"text-align:right")
        rows << content_tag(:tr, cells)
      end
      html << content_tag(:table, rows)
    else
      html << content_tag(:p, "Query data unavailable", :class=>"alt")
    end

    html
  end

  def display_most_recent_date_available(day)
    return "Query data currently unavailable" if day.nil?
    html = "Data for #{day.to_s(:long)}"
    firstdate = DailyQueryStat.minimum(:day)
    first = [firstdate.year, (firstdate.month.to_i - 1), firstdate.day].join(',')
    lastdate = DailyQueryStat.maximum(:day)
    last = [lastdate.year, (lastdate.month.to_i - 1), lastdate.day].join(',')
    html<< calendar_date_select_tag("pop_up_hidden", "", :hidden => true, :buttons => false, :onchange => "location = '/analytics/?day='+$F(this);", :valid_date_check => "date <= (new Date(#{last})).stripTime() && date >= (new Date(#{first})).stripTime()")
  end

  def display_select_for_window(window, num_results, day)
    options = [10, 50, 100, 500, 1000].collect{ |x| ["Show #{x} results", x] }
    select_tag("num_results_select#{window}", options_for_select( options, num_results), { :onchange => "location = '/analytics/?day=#{day}&num_results#{window}='+this.options[this.selectedIndex].value;"})
  end
end