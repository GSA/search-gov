# frozen_string_literal: true

class SearchgovUrlBulkUploaderJob < ApplicationJob
  queue_as :searchgov

  delegate :upload_and_index, to: :@uploader

  def perform(user, filename, urls)
    @user = user
    @uploader = BulkUrlUploader.new(filename, urls)

    upload_and_index
    report_results
  end

  def report_results
    log_results
    send_results_email
  end

  def log_results
    results = @uploader.results
    Rails.logger.info "SearchgovUrlBulkUploaderJob: #{results.name}"
    Rails.logger.info "    #{results.total_count} URLs"
    Rails.logger.info "    #{results.error_count} errors"
  end

  def send_results_email
    results = @uploader.results
    email = BulkUrlUploadResultsMailer.with(user: @user, results: results).results_email
    email.deliver_now!
  end
end
