class SearchElastic::DocumentSearch
  NO_HITS = { "hits" => { "total" => 0, "hits" => [] }}

  attr_reader :doc_query, :offset, :size, :indices

  def initialize(options)
    @doc_query = SearchElastic::DocumentQuery.new(options)
    @indices = options[:indices]
    @offset = options[:offset] || 0
    @size = options[:size]
  end

  def search
    i14y_search_results = execute_client_search
    if i14y_search_results.total.zero? && i14y_search_results.suggestion.present?
      suggestion = i14y_search_results.suggestion
      doc_query.query = suggestion['text']
      i14y_search_results = execute_client_search
      i14y_search_results.override_suggestion(suggestion) if i14y_search_results.results.present?
    end
    i14y_search_results
  end

  private

  def execute_client_search
    Rails.logger.debug "Query: *****\n#{doc_query.body.to_json}\n*****"

    result = ES.client.search({
      index: indices,
      body: doc_query.body,
      from: offset,
      size: size,
      rest_total_hits_as_int: true
    })

    SearchElastic::DocumentSearchResults.new(result, offset)
  end
end
