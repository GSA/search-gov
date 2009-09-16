module Analytics::HomeHelper
  def display_most_popular(pairs)
    html = content_tag(:h3, "Most Popular")
    if pairs
      rows = ""
      count = 1
      pairs.each_pair do |query, times|
        query_link = link_to(query, query_timeline_path(query))
        query_item = "#{count}. #{query_link}"
        cells = content_tag(:td, query_item, :style=>"text-align:left")
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
        query_item = "#{count + 1}. #{query_link}"
        cells = content_tag(:td, query_item, :style=>"text-align:left")
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
    day.nil? ? "Query data currently unavailable" : "Data for #{day.to_s(:long)}"
  end

  def display_select_for_window(window, num_results)
    options = [10, 50, 100, 500, 1000].collect{ |x| ["Show #{x} results",x] }
    select_tag("num_results_select#{window}", options_for_select( options, num_results), { :onchange => "location = '/analytics/?num_results#{window}='+this.options[this.selectedIndex].value;"})
  end
end