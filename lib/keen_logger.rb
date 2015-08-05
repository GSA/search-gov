class KeenLogger
  def self.log(collection, keen_hash)
    ActiveSupport::Notifications.instrument("keen_publish.usasearch", :query => keen_hash) do
      Keen.publish_async(collection, keen_hash)
    end
  rescue Keen::Error, RuntimeError => e
    Rails.logger.error "Problem publishing event to Keen: #{e}"
  end
end