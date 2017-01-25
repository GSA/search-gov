module SearchOnCommercialEngine
  def search
    notification_name = "#{@search_engine.class.name.tableize.singularize}.usasearch"
    ActiveSupport::Notifications.instrument(notification_name, query: { term: @search_engine.query }) do
      result = @search_engine.execute_query
      diagnostics[diagnostics_label] = result.diagnostics
      result
    end
  rescue SearchEngine::SearchError => error
    Rails.logger.warn "Error getting search results for #{@affiliate.name} from #{@search_engine.class.name} API endpoint: #{error}"
    diagnostics[diagnostics_label] = { error: "COMMERCIAL_API_ERROR: #{error}" }
    false
  end
end
