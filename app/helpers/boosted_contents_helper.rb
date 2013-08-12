module BoostedContentsHelper
  def boosted_content_status_class_hash(boosted_content)
    boosted_content.active_and_searchable? ? { class: 'success'} : { class: 'warning' }
  end

  def boosted_content_status_and_dates_item(boosted_content)
    status_class = boosted_content.is_active? ? 'label-info' : 'label-important'
    content = content_tag(:span, 'Status: ', class: 'description')
    content << content_tag(:span, "#{boosted_content.display_status}", class: "label #{status_class}")
    formatted_publish_start_date = boosted_content.publish_start_on.strftime('%m/%d/%Y')
    if boosted_content.publish_end_on
      formatted_publish_end_date = boosted_content.publish_end_on.strftime('%m/%d/%Y')
      content << " / Published between #{formatted_publish_start_date} and #{formatted_publish_end_date}."
    else
      content << " / Published since #{formatted_publish_start_date}."
    end
    content_tag :li, content.html_safe
  end

  def boosted_content_keywords_item(boosted_content)
    return unless boosted_content.boosted_content_keywords.present?
    content = content_tag(:span, 'Keywords: ', class: 'description')
    keyword_items = boosted_content.boosted_content_keywords.map do |keyword|
      content_tag :li, keyword.value, class: 'label'
    end
    content << content_tag(:ul, keyword_items.join.html_safe, class: 'keywords')
    content_tag :li, content.html_safe
  end
end
