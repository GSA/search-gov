# frozen_string_literal: true

class WatcherObserver < ActiveRecord::Observer
  def after_save(watcher)
    return if opensearch_analytics_enabled?

    Es::ELK.client_reader.xpack.watcher.put_watch(id: watcher.id, body: watcher.body)
  rescue StandardError => e
    Rails.logger.error("Failed to create/update Watcher alert: #{e.message}")
  end

  def after_destroy(watcher)
    return if opensearch_analytics_enabled?

    Es::ELK.client_reader.xpack.watcher.delete_watch(id: watcher.id)
  rescue StandardError => e
    Rails.logger.error("Failed to delete Watcher alert: #{e.message}")
  end

  private

  def opensearch_analytics_enabled?
    OpenSearchConfig.enabled?
  end
end
