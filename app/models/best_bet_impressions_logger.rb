class BestBetImpressionsLogger
  class << self
    def log(affiliate_id, query, featured_collections, boosted_contents)
      normalized_query = query.downcase
      log_best_bets(affiliate_id, normalized_query, 'BBG', featured_collections) if featured_collections and featured_collections.total > 0
      log_best_bets(affiliate_id, normalized_query, 'BOOS', boosted_contents) if boosted_contents and boosted_contents.results
    end

    private

    def log_best_bets(affiliate_id, query, module_tag, best_bets_collection)
      best_bets_collection.results.each do |best_bet|
        KeenLogger.log(:impressions, { :affiliate_id => affiliate_id, :module => module_tag, :query => query, :model_id => best_bet.id })
      end
    end

  end
end