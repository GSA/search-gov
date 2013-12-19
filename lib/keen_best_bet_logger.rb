class KeenBestBetLogger
  def self.log(collection, keen_hash)
    ActiveSupport::Notifications.instrument("best_bets_publish.usasearch", :query => keen_hash) do
      Keen.publish_async(collection, keen_hash)
    end
  rescue Keen::Error, RuntimeError => e
    Rails.logger.error "Problem publishing Best Bet event to Keen: #{e}"
  end
end