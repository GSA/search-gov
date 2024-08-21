# frozen_string_literal: true

class IndexURLsController < ApplicationController
  skip_before_action :verify_authenticity_token
  wrap_parameters false

  attr_reader :index_urls

  def start
    begin
      @job_id = params[:job_id]
      @index_urls = params[:index_urls]
      @job = enqueue_job
    rescue BulkUrlUploader::Error => e
      Rails.logger.error 'Failed to index urls:', e
      render json: e.message, status: :bad_request
    end
    render json: @job.json_results, status: :success
  end

  private

  def permitted_params
    params.permit(
      :job_id,
      :index_urls
    )
  end

  def enqueue_job
    SearchgovIndexURLsJob.perform_later(
      @job_id,
      @index_urls
    )
  end
end
