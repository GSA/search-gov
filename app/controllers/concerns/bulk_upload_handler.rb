# frozen_string_literal: true

module BulkUploadHandler
  def handle_bulk_upload(options)
    @file = params[options[:params_key]]
    validate_file(@file, options[:validator_class])
    perform_upload(@file)
  rescue options[:error_class] => e
    handle_upload_error(e, options)
  ensure
    redirect_to options[:success_path]
  end

  private

  def validate_file(file, validator_class)
    validator_class.new(file).validate!
  end

  def perform_upload(file)
    enqueue_job
    flash[:success] = success_message(file.original_filename)
  end

  def handle_upload_error(error, options)
    Rails.logger.error options[:logger_message], error
    flash[:error] = error.message
  end
end
