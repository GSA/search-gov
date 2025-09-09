# frozen_string_literal: true

class OpenSearch::DocumentSearch < SearchElastic::DocumentSearch
  def initialize(options, affiliate:)
    @doc_query = OpenSearch::DocumentQuery.new(options, affiliate:)
    @indices = options[:indices]
    @offset = options[:offset] || 0
    @size = options[:size]
  end

  private

  def execute_client_search
    Rails.logger.debug "Query: *****\n#{doc_query.body.to_json}\n*****"

    result = ES_OS.search({
      index: indices,
      body: doc_query.body,
      from: offset,
      size: size,
      rest_total_hits_as_int: true
    })

    OpenSearch::DocumentSearchResults.new(result, offset)
  end
end
