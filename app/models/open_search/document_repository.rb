# frozen_string_literal: true

class OpenSearch::DocumentRepository < SearchElastic::DocumentRepository
  client OPENSEARCH_CLIENT
end
