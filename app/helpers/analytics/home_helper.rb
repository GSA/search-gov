module Analytics::HomeHelper
  def display_most_popular(popular_pairs)
    html = content_tag(:h3, "Most Popular")
    if popular_pairs
      rows = ""
      popular_pairs.each_pair do |query, times|
        cells = content_tag(:td, query.downcase, :style=>"text-align:left")
        cells << content_tag(:td, times, :style=>"text-align:right")
        rows << content_tag(:tr, cells)
      end
      html << content_tag(:table, rows)
    else
      html << content_tag(:p, "Query data unavailable", :class=>"alt")
    end

    html
  end
end