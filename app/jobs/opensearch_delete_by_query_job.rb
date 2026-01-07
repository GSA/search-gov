# frozen_string_literal: true

class OpenSearchDeleteByQueryJob < DeleteByQueryBaseJob

  private

  def client
    OPENSEARCH_CLIENT
  end

  def index_name
    ENV.fetch('OPENSEARCH_SEARCH_INDEX')
  end

  def retention_days_env_key
    'OPENSEARCH_SEARCH_RETENTION_DAYS'
  end
end
