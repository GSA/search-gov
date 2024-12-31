# frozen_string_literal: true

module BulkUploadHandler
  def handle_bulk_upload(params_key:, validator_class:, error_class:, success_path:, logger_message:)
    @file = params[params_key]
    validate_file(@file, validator_class)
    perform_upload(@file)
  rescue error_class => e
    handle_upload_error(logger_message, e)
  ensure
    redirect_to success_path
  end

  private

  def validate_file(file, validator_class)
    validator_class.new(file).validate!
  end

  def perform_upload(file)
    enqueue_job
    flash[:success] = success_message(file.original_filename)
  end

  def handle_upload_error(logger_message, error)
    Rails.logger.error logger_message, error
    flash[:error] = error.message
  end
end
