module BoostedContentsHelper
  def boosted_content_keywords_item(boosted_content)
    best_bets_keywords_items(boosted_content.boosted_content_keywords) if boosted_content.boosted_content_keywords.present?
  end
end
