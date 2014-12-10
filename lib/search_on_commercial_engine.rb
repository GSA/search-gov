module SearchOnCommercialEngine
  def search
    notification_name = "#{@search_engine.class.name.tableize.singularize}.usasearch"
    ActiveSupport::Notifications.instrument(notification_name, query: { term: @search_engine.query }) do
      @search_engine.execute_query
    end
  rescue SearchEngine::SearchError => error
    Rails.logger.warn "Error getting search results for #{@affiliate.name} from #{@search_engine.class.name} API endpoint: #{error}"
    false
  end
end
