# frozen_string_literal: true

class UrlsController < ApplicationController
  skip_before_action :verify_authenticity_token
  wrap_parameters false

  def create
    urls = params[:urls]
    if urls.nil?
      render json: { error: "The 'urls' parameter is required." }, status: '422'
      return nil
    end
    scheduled_job = enqueue_job(urls)
    response = {
      job_id: scheduled_job.job_id
    }
    Rails.logger.info "'/urls': #{scheduled_job.job_id} job added to the queue", total_count: urls.count
    render json: response, status: :ok
  end

  private

  def enqueue_job(urls)
    SearchgovUrlsJob.perform_later('bulk_url_indexer_endpoint', urls)
  end
end
