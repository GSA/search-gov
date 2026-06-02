# frozen_string_literal: true

class OpenSearch::DocumentSearch
  NO_HITS = { "hits" => { "total" => 0, "hits" => [] }}

  attr_reader :doc_query, :offset, :size, :indices

  def initialize(options, affiliate:)
    @doc_query = OpenSearch::DocumentQuery.new(options, affiliate:)
    @indices = options[:indices]
    @offset = options[:offset] || 0
    @size = options[:size]
  end

  def search
    search_results = execute_client_search
    if search_results.total.zero? && search_results.suggestion.present?
      suggestion = search_results.suggestion
      doc_query.query = suggestion['text']
      search_results = execute_client_search
      search_results.override_suggestion(suggestion) if search_results.results.present?
    end
    search_results
  end

  private

  def execute_client_search
    Rails.logger.debug "Query: *****\n#{doc_query.body.to_json}\n*****"

    result = OPENSEARCH_CLIENT.search({
      index: indices,
      body: doc_query.body,
      from: offset,
      size: size,
      rest_total_hits_as_int: true
    })

    OpenSearch::DocumentSearchResults.new(result, offset)
  end
end
