# frozen_string_literal: true

class BulkAffiliateStylesUploaderJob < ApplicationJob
  queue_as :searchgov

  def perform(user, filename, filepath)
    @user = user
    @filename = filename
    @uploader = BulkAffiliateStylesUploader.new(filename, filepath)
    @uploader.upload
    report_results
  end

  def report_results
    log_results
    send_results_email
  end

  def log_results
    results = @uploader.results
    Rails.logger.info "BulkAffiliateStylesUploaderJob: #{results.file_name}"
    Rails.logger.info "    #{results.total_count} affiliates"
    Rails.logger.info "    #{results.error_count} errors"
  end

  def send_results_email
    results = @uploader.results
    email = BulkAffiliateStylesUploadResultsMailer.with(user: @user, results:).results_email
    email.deliver_now!
  end
end
