# frozen_string_literal: true

require 'elasticsearch/transport'

class DeleteByQueryBaseJob < ApplicationJob
  queue_as :searchgov

  DEFAULT_REQUESTS_PER_SECOND = 500
  DEFAULT_SCROLL_SIZE = 5000
  START_RETRY_ATTEMPTS = 3
  REDIS_KEY_PREFIX = "delete_by_query:task_id"

  # Generic "Safe List" of errors that exist in most gem versions and in both Elasticsearch and OpenSearch clients.
  # Covers: Server overloaded (503), Network timeouts, and Connection failures
  retry_on Elasticsearch::Transport::Transport::Errors::ServiceUnavailable,
           Faraday::TimeoutError,
           Faraday::ConnectionFailed,
           Errno::ETIMEDOUT,
           wait: ->(executions) { 2**executions },
           attempts: START_RETRY_ATTEMPTS do |job, error|
    Rails.logger.warn { "Transient error starting delete_by_query (attempt=#{job.executions + 1}) for #{job.class}: #{error.class}: #{error.message}; will retry" }
  end

  def perform
    retention_days = ENV.fetch(retention_days_env_key).to_i

    Rails.logger.info { "#{self.class.name} starting for index=#{index_name}, retention_days=#{retention_days}" }

    previous_task_id = redis_get_task_id(index_name)

    # Cancel previous async task, if one existed
    if previous_task_id.present?
      cancel_previous_task(previous_task_id)
    end

    body = {
      query: {
        range: {
          updated_at: { lt: "now-#{retention_days}d/d" }
        }
      }
    }

    response = client.delete_by_query(
      index: index_name,
      body: body,
      slices: 'auto',
      requests_per_second: DEFAULT_REQUESTS_PER_SECOND,
      conflicts: 'proceed',
      scroll_size: DEFAULT_SCROLL_SIZE,
      refresh: false,
      wait_for_completion: false,
      timeout: '30m'
    )

    task_id = response.is_a?(Hash) && response['task'] ? response['task'] : nil

    if task_id.nil?
      deleted = response['deleted'] || 0
      Rails.logger.info { "delete_by_query completed synchronously; deleted=#{deleted} index=#{index_name}" }
      redis_clear_task_id(index_name)
      return
    end

    Rails.logger.info { "delete_by_query started async task_id=#{task_id} index=#{index_name}" }
    redis_set_task_id(index_name, task_id)
  end

  private

  # Abstract methods to be implemented by subclasses. Eventhough we are using Elasticsearch client for both
  # ES and OpenSearch, the error classes differ, so we need to have separate subclasses for each.
  def client
    raise NotImplementedError, "#{self.class.name} must implement #client"
  end

  def index_name
    raise NotImplementedError, "#{self.class.name} must implement #index_name"
  end

  def retention_days_env_key
    raise NotImplementedError, "#{self.class.name} must implement #retention_days_env_key"
  end

  def redis
    @redis ||= Redis.new(url: ENV.fetch("REDIS_SYSTEM_URL"))
  end

  def redis_key_for(index)
    "#{REDIS_KEY_PREFIX}:#{index}"
  end

  def redis_get_task_id(index)
    redis.get(redis_key_for(index))
  rescue StandardError => e
    Rails.logger.warn { "Redis get failed for index=#{index}: #{e.class}: #{e.message}" }
    nil
  end

  def redis_set_task_id(index, task_id)
    redis.set(redis_key_for(index), task_id)
  rescue StandardError => e
    Rails.logger.error { "Redis set failed for index=#{index} task_id=#{task_id}: #{e.class}: #{e.message}" }
  end

  def redis_clear_task_id(index)
    redis.del(redis_key_for(index))
  rescue StandardError => e
    Rails.logger.warn { "Redis delete failed for index=#{index}: #{e.class}: #{e.message}" }
  end

  def cancel_previous_task(task_id)
    Rails.logger.info { "Cancelling previous delete_by_query task_id=#{task_id} index=#{index_name}" }
    client.tasks.cancel(task_id: task_id)
  rescue StandardError => e
    # We need to catch StandardError because the specific NotFound errors differ between ES/OpenSearch
    # and we want to be resilient regardless of the client namespace
    if e.class.name.end_with?('NotFound')
      Rails.logger.warn { "Previous task #{task_id} not found during cancel: #{e.message}" }
    else
      Rails.logger.error { "Error cancelling previous task #{task_id}: #{e.class}: #{e.message}" }
    end
  end
end
