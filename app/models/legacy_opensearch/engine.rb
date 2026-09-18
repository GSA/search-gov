# frozen_string_literal: true

class LegacyOpenSearch::Engine < OpenSearch::Engine
  def search_index
    ENV.fetch('LEGACY_OPENSEARCH_INDEX')
  end
end
