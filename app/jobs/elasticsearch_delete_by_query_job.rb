# frozen_string_literal: true

class ElasticsearchDeleteByQueryJob < DeleteByQueryBaseJob

  private

  def client
    ES.client
  end

  def index_name
    ENV.fetch('SEARCHELASTIC_INDEX')
  end

  def retention_days_env_key
    # This is not a typo; we use OPENSEARCH_SEARCH_RETENTION_DAYS, even for Elasticsearch
    'OPENSEARCH_SEARCH_RETENTION_DAYS'
  end
end
