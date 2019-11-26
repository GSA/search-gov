class RoutedQueryKeywordObserver < ActiveRecord::Observer
  def after_create(routed_query_keyword)
    SaytSuggestion.create(phrase: routed_query_keyword.keyword,
                          affiliate: routed_query_keyword.routed_query.affiliate,
                          is_protected: true,
                          popularity: SaytSuggestion::MAX_POPULARITY)
  end

  def after_update(routed_query_keyword)
    sayt_suggestion = SaytSuggestion.find_by_affiliate_id_and_phrase_and_is_protected(routed_query_keyword.routed_query.affiliate.id,
                                                                                      routed_query_keyword.attribute_before_last_save('keyword'),
                                                                                      true)
    sayt_suggestion.update_attribute(:phrase, routed_query_keyword.keyword) if sayt_suggestion.present?
  end

  def after_destroy(routed_query_keyword)
    sayt_suggestion = SaytSuggestion.find_by_affiliate_id_and_phrase_and_is_protected(routed_query_keyword.routed_query.affiliate.id,
                                                                                      routed_query_keyword.keyword,
                                                                                      true)
    sayt_suggestion.destroy if sayt_suggestion.present?
  end
end
