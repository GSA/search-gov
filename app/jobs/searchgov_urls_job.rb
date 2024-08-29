# frozen_string_literal: true

class SearchgovUrlsJob < ApplicationJob
  queue_as :searchgov

  def perform(name, urls)
    @time_started = Time.zone.now
    @total_count = urls.count
    @uploader = BulkUrlUploader.new(name, urls)
    @uploader.upload_and_index
    log_results
  end

  def log_results
    results = @uploader.results
    Rails.logger.info "SearchgovUrlsJob: #{results.name}", total_count: results.total_count, errors_count: results.error_count, start_time: @time_started, end_time: Time.zone.now
  end
end
