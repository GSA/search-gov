module BoostedContentsHelper
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
