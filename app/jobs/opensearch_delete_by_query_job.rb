# frozen_string_literal: true

class OpensearchDeleteByQueryJob < DeleteByQueryBaseJob
  # specific OpenSearch errors
  retry_on OpenSearch::Transport::Transport::Errors::ServiceUnavailable,
           OpenSearch::Transport::Transport::Errors::TooManyRequests,
           Faraday::TimeoutError,
           Errno::ETIMEDOUT,
           wait: ->(executions) { 2**executions },
           attempts: START_RETRY_ATTEMPTS do |job, error|
    Rails.logger.warn { "Transient error starting OS delete_by_query (attempt=#{job.executions + 1}): #{error.class}: #{error.message}; will retry" }
  end

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
