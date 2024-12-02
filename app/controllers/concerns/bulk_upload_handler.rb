# frozen_string_literal: true

module BulkUploadHandler
  def handle_bulk_upload(options)
    @file = params[options[:params_key]]
    options[:validator_class].new(@file).validate!
    enqueue_job
    flash[:success] = success_message(@file.original_filename)
  rescue options[:error_class] => e
    Rails.logger.error options[:logger_message], e
    flash[:error] = e.message
  ensure
    redirect_to options[:success_path]
  end
end
