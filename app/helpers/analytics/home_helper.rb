module Analytics::HomeHelper
  def open_close_toggle_icon(name, id)
    link_to(image_tag("item_closed.png", :alt => "Click to open/close", :size => "16x16", :id => "#{name}toggle#{id}"),
            "javascript:void(0)", {:title => "Click to open/close",
                                   :onClick=>"new Effect.toggle('#{name}item#{id}', 'blind', {duration: 0.5,beforeStart:function(){ image = document.getElementById('#{name}toggle#{id}'); image.src = ( image.src.match('opened') ) ? '/images/item_closed.png' : '/images/item_opened.png'; }})"})
  end

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
    "#{prefix}_top_queries_#{report_date.strftime('%Y%m')}.csv"
  end

  def daily_report_filename(prefix, report_date)
    "#{prefix}_top_queries_#{report_date.strftime('%Y%m%d')}.csv"
  end
   
  private
  def make_query_timeline_path(query_count)
    query_count.children.empty? ? query_timeline_path(query_count.query) : query_timeline_path(query_count.query, :grouped => 1)
  end
end