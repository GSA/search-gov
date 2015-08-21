module UsersHelper
  def filtered_analytics_toggle(current_user)
    description_class = 'description label off-screen-text'
    if current_user.sees_filtered_totals?
      description_class << ' label-warning'
      verb = 'Stop filtering'
    else
      verb = 'Filter'
    end
    title = "#{verb} bot traffic"
    wrapper_options = { :id => 'filtered-analytics-toggle',
                        :'data-toggle' => 'tooltip',
                        :'data-original-title' => title,
                        :method => :create }

    link_to site_filtered_analytics_toggle_path(@site), wrapper_options do
      inner_html = stacked_filter
      inner_html << content_tag(:span, title, class: description_class)
      if current_user.sees_filtered_totals?
        content_tag :div, inner_html, class: 'disabled'
      else
        inner_html
      end
    end
  end
end
