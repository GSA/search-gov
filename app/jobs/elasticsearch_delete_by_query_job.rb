# frozen_string_literal: true

class ElasticsearchDeleteByQueryJob < DeleteByQueryBaseJob
  # specific Elasticsearch errors
  retry_on Elasticsearch::Transport::Transport::Errors::ServiceUnavailable,
           Faraday::TimeoutError,
           Errno::ETIMEDOUT,
           wait: ->(executions) { 2**executions },
           attempts: START_RETRY_ATTEMPTS do |job, error|
    Rails.logger.warn { "Transient error starting ES delete_by_query (attempt=#{job.executions + 1}): #{error.class}: #{error.message}; will retry" }
  end

  private

  def client
    ES.client
  end

  def index_name
    ENV.fetch('SEARCHELASTIC_INDEX')
  end

  def retention_days_env_key
    'OPENSEARCH_SEARCH_RETENTION_DAYS'
  end
end
