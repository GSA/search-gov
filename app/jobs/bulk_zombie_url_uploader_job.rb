# frozen_string_literal: true

class BulkZombieUrlUploaderJob < ApplicationJob
  queue_as :searchgov

  delegate :upload, to: :@uploader

  def perform(user, filename, filepath)
    @user = user
    @filename = filename

    s3_client = Aws::S3::Client.new(region: ENV['AWS_REGION'])
    response = s3_client.get_object(bucket: ENV['AWS_BUCKET'], key: filepath)

    local_filepath = Rails.root.join('tmp', filename)
    File.open(local_filepath, 'wb') { |file| file.write(response.body.read) }

    @uploader = BulkZombieUrlUploader.new(filename, local_filepath)
    upload

    File.delete(local_filepath) if File.exist?(local_filepath)
    report_results
  end

  private

  def report_results
    log_results
    send_results_email
  end

  def log_results
    results = @uploader.results
    Rails.logger.info(BulkZombieUrlUploaderJob: results.file_name, total_urls: results.total_count, errors:  results.error_count)
  end

  def send_results_email
    results = @uploader.results
    email = BulkZombieUrlUploadResultsMailer.with(user: @user, results:).results_email
    email.deliver_now!
  end
end
