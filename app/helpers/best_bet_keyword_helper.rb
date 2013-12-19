module BestBetKeywordHelper
  def best_bets_keywords_items(best_bet_keywords)
    content = content_tag(:span, 'Keywords: ', class: 'description')
    keyword_items = best_bet_keywords.map do |keyword|
      content_tag :li, keyword.value, class: 'label'
    end
    content << content_tag(:ul, keyword_items.join.html_safe, class: 'keywords')
    content_tag :li, content.html_safe
  end
end
