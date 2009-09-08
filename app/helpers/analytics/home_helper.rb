module Analytics::HomeHelper
  def display_most_popular(pairs)
    html = content_tag(:h3, "Most Popular")
    if pairs
      rows = ""
      pairs.each_pair do |query, times|
        cells = content_tag(:td, query, :style=>"text-align:left")
        cells << content_tag(:td, times, :style=>"text-align:right")
        rows << content_tag(:tr, cells)
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
      query_accelerations.each do |qa|
        cells = content_tag(:td, qa.query, :style=>"text-align:left")
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
end