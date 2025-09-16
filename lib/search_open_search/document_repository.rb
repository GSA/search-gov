# frozen_string_literal: true

require_relative '../search_elastic/document_repository'

class SearchOpenSearch::DocumentRepository < SearchElastic::DocumentRepository
  client OPENSEARCH_CLIENT
end
