# frozen_string_literal: true

class SearchgovIndexURLsJob < ApplicationJob
  queue_as :searchgov
  delegate :upload_and_index, to: :@uploader

  def perform(job_id, urls)
    @time_started = Time.zone.now
    @total_count = urls.count
    @uploader = BulkUrlUploader.new(job_id, urls)

    upload_and_index
    log_results
  end

  def json_results
    results = @uploader.results
    {
      job_id: results.name,
      start_time: @time_started,
      end_time: Time.zone.now,
      indexed_count: results.total_count,
      failed_count: results.error_count,
      total_count: @total_count,
      failed_urls: results.errors
    }.to_json
  end

  def log_results
    results = @uploader.results
    Rails.logger.info "SearchgovIndexURLsJob: #{results.name}"
    Rails.logger.info "    #{results.total_count} URLs"
    Rails.logger.info "    #{results.error_count} errors"
  end
end
