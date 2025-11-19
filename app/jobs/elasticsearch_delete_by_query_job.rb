# frozen_string_literal: true

# Deletes documents from the Elasticsearch index where "updated_at" field is older than the configured retention days
# - Starts async delete_by_query and stores ES task id in Redis
# - On each run: cancels previous task, and starts a new one
# - Uses ActiveJob retry_on for transient start errors
class ElasticsearchDeleteByQueryJob < ApplicationJob
  queue_as :searchgov

  DEFAULT_REQUESTS_PER_SECOND = 500
  DEFAULT_SCROLL_SIZE = 5000
  START_RETRY_ATTEMPTS = 3
  REDIS_KEY_PREFIX = "elasticsearch_delete_by_query:task_id"

  retry_on Elasticsearch::Transport::Transport::Errors::ServiceUnavailable,
           Faraday::TimeoutError,
           Errno::ETIMEDOUT,
           wait: ->(executions) { 2**executions },
           attempts: START_RETRY_ATTEMPTS do |job, error|
    Rails.logger.warn { "Transient error starting delete_by_query (attempt=#{job.executions + 1}): #{error.class}: #{error.message}; will retry" }
  end

  def perform
    index = ENV.fetch('SEARCHELASTIC_INDEX')
    retention_days_str = ENV.fetch('OPENSEARCH_SEARCH_RETENTION_DAYS')
    retention_days = retention_days_str.to_i

    Rails.logger.info { "ElasticsearchDeleteByQueryJob starting for index=#{index}, retention_days=#{retention_days}" }

    previous_task_id = redis_get_task_id(index)

    # Cancel previous async task, if one existed
    if previous_task_id.present?
      begin
        Rails.logger.info { "Cancelling previous delete_by_query task_id=#{previous_task_id} index=#{index}" }
        ES.client.tasks.cancel(task_id: previous_task_id)
      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        Rails.logger.warn { "Previous ES task #{previous_task_id} not found during cancel: #{e.message}" }
      rescue StandardError => e
        Rails.logger.error { "Error cancelling previous ES task #{previous_task_id}: #{e.class}: #{e.message}" }
      end
    end

    body = {
      query: {
        range: {
          updated_at: { lt: "now-#{retention_days}d/d" }
        }
      }
    }

    requests_per_second = DEFAULT_REQUESTS_PER_SECOND
    scroll_size = DEFAULT_SCROLL_SIZE
    slices = 'auto'

    response = ES.client.delete_by_query(
      index: index,
      body: body,
      slices: slices,
      requests_per_second: requests_per_second,
      conflicts: 'proceed',
      scroll_size: scroll_size,
      refresh: false,
      wait_for_completion: false,
      timeout: '30m'
    )

    task_id = response.is_a?(Hash) && response['task'] ? response['task'] : nil

    if task_id.nil?
      deleted = response['deleted'] || 0
      Rails.logger.info { "delete_by_query completed synchronously; deleted=#{deleted} index=#{index}" }
      redis_clear_task_id(index)
      return
    end

    Rails.logger.info { "delete_by_query started async task_id=#{task_id} index=#{index} slices=#{slices} rps=#{requests_per_second}" }

    redis_set_task_id(index, task_id)
  end

  private

  @@redis ||= Redis.new(url: ENV.fetch("REDIS_SYSTEM_URL"))
  
  def redis_key_for(index)
    "#{REDIS_KEY_PREFIX}:#{index}"
  end

  def redis_get_task_id(index)
    @@redis.get(redis_key_for(index))
  rescue StandardError => e
    Rails.logger.warn { "Redis get failed for index=#{index}: #{e.class}: #{e.message}" }
    nil
  end

  def redis_set_task_id(index, task_id)
    @@redis.set(redis_key_for(index), task_id)
  rescue StandardError => e
    Rails.logger.error { "Redis set failed for index=#{index} task_id=#{task_id}: #{e.class}: #{e.message}" }
  end

  def redis_clear_task_id(index)
    @@redis.del(redis_key_for(index))
  rescue StandardError => e
    Rails.logger.warn { "Redis delete failed for index=#{index}: #{e.class}: #{e.message}" }
  end

end
