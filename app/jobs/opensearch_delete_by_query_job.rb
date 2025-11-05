# frozen_string_literal: true

# Deletes documents from the OpenSearch index where "updated_at" field is older than the configured retention days
# - Uses async delete_by_query and polls task progress
# - Configurable throttling and defaults

class OpensearchDeleteByQueryJob < ApplicationJob
  queue_as :searchgov

  DEFAULT_REQUESTS_PER_SECOND = 500
  DEFAULT_SCROLL_SIZE = 5000
  DEFAULT_MAX_TASK_WAIT_SECONDS = 23 * 60 * 60 # 23h
  START_RETRY_ATTEMPTS = 3

  def perform
    index = fetch_env!('SEARCHELASTIC_INDEX')
    retention_days = fetch_retention_days!

    Rails.logger.info { "OpenSearchDeleteByQueryJob starting for index=#{index}, retention_days=#{retention_days}" }

    body = {
      query: {
        range: {
          updated_at: { lt: "now-#{retention_days}d/d" }
        }
      }
    }

    requests_per_second = DEFAULT_REQUESTS_PER_SECOND
    scroll_size = DEFAULT_SCROLL_SIZE
    max_wait_seconds = DEFAULT_MAX_TASK_WAIT_SECONDS

    slices = 'auto'

    response = with_start_retries(index, body, slices, requests_per_second, scroll_size)

    task_id = (response.is_a?(Hash) && response['task']) ? response['task'] : nil

    if task_id.nil?
      deleted = (response && response['deleted']) || 0
      Rails.logger.info { "delete_by_query completed synchronously; deleted=#{deleted} index=#{index}" }
      return
    end

    Rails.logger.info { "delete_by_query started async task_id=#{task_id} index=#{index} slices=#{slices} rps=#{requests_per_second}" }

    begin
      result = wait_for_task_completion(task_id, max_wait_seconds)
      if result[:completed]
        deleted = result[:deleted] || 0
        Rails.logger.info { "Async delete_by_query finished for index=#{index}: deleted=#{deleted}" }
      else
        Rails.logger.warn { "Async delete_by_query for index=#{index} did not finish within #{max_wait_seconds}s; task_id=#{task_id}" }
        OPENSEARCH_CLIENT.tasks.cancel(task_id: task_id)
      end
    rescue OpenSearch::Transport::Transport::Errors::NotFound => e
      Rails.logger.error { "Task not found while monitoring delete_by_query for index=#{index}: #{e.message}" }
      raise
    rescue StandardError => e
      Rails.logger.error { "Unexpected error while monitoring delete_by_query for index=#{index}: #{e.message}" }
      raise
    end
  end

  private

  def fetch_env!(key)
    ENV.fetch(key) { raise KeyError, "#{key} must be set in environment" }
  end

  def fetch_retention_days!
    s = fetch_env!('SEARCHELASTIC_RETENTION_DAYS')
    unless s =~ /\A\d+\z/
      raise ArgumentError, 'SEARCHELASTIC_RETENTION_DAYS must be a positive integer'
    end

    days = s.to_i
    raise ArgumentError, 'SEARCHELASTIC_RETENTION_DAYS must be greater than 0' if days <= 0

    days
  end

  def with_start_retries(index, body, slices, requests_per_second, scroll_size)
    attempt = 0
    begin
      attempt += 1
      OPENSEARCH_CLIENT.delete_by_query(
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
    rescue OpenSearch::Transport::Transport::Errors::TooManyRequests, OpenSearch::Transport::Transport::Errors::ServiceUnavailable, Faraday::TimeoutError, Errno::ETIMEDOUT => e
      if attempt <= START_RETRY_ATTEMPTS
        sleep_time = 2**attempt
        Rails.logger.warn { "Transient error starting delete_by_query (attempt=#{attempt}) for index=#{index}: #{e.class}: #{e.message}; retrying in #{sleep_time}s" }
        sleep(sleep_time)
        retry
      else
        Rails.logger.error { "Failed to start delete_by_query after #{START_RETRY_ATTEMPTS} attempts for index=#{index}: #{e.class}: #{e.message}" }
        raise
      end
    end
  end

  def wait_for_task_completion(task_id, max_wait_seconds)
    start_time = Time.now
    attempt = 0

    loop do
      attempt += 1
      elapsed = Time.now - start_time
      break({ completed: false }) if elapsed > max_wait_seconds

      begin
        resp = OPENSEARCH_CLIENT.tasks.get(task_id: task_id)
      rescue OpenSearch::Transport::Transport::Errors::NotFound => e
        Rails.logger.warn { "Task #{task_id} not found while polling: #{e.message}" }
        return { completed: false }
      end

      if resp.is_a?(Hash) && resp['completed']
        deleted = resp.dig('response', 'deleted') || resp.dig('response', 'total')
        return { completed: true, deleted: deleted }
      end

      sleep_seconds = [1, 2**(attempt / 2)].max
      Rails.logger.info { "Waiting for delete_by_query task #{task_id} to complete (elapsed=#{elapsed.round}s). Sleeping #{sleep_seconds.round}s" }
      sleep(sleep_seconds)
    end
  end
end
