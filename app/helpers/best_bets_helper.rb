module BestBetsHelper
  def best_bets_status_class_hash(boosted_content)
    boosted_content.active_and_searchable? ? { class: 'success' } : { class: 'warning' }
  end

  def best_bets_status_and_dates_item(bb)
    status_class = bb.is_active? ? 'label-info' : 'label-important'
    content = content_tag(:span, 'Status: ', class: 'description')
    content << content_tag(:span, "#{bb.display_status}", class: "label #{status_class}")
    if bb.match_keyword_values_only?
      content << " / "
      content << content_tag(:span, "Match Keywords Only", class: "label label-warning")
    end
    formatted_publish_start_date = bb.publish_start_on.strftime('%m/%d/%Y')
    if bb.publish_end_on
      formatted_publish_end_date = bb.publish_end_on.strftime('%m/%d/%Y')
      content << " / Published between #{formatted_publish_start_date} and #{formatted_publish_end_date}."
    else
      content << " / Published since #{formatted_publish_start_date}."
    end
    content_tag :li, content.html_safe
  end
end
