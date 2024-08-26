# frozen_string_literal: true

class IndexURLsController < ApplicationController
  skip_before_action :verify_authenticity_token
  wrap_parameters false

  attr_reader :job_id, :urls

  def start
    job_id = params[:job_id]
    urls = params[:urls]
    job = enqueue_job(job_id, urls)
    render json: job.json_results, status: :success
  end

  private

  def permitted_params
    params.permit(
      :job_id,
      :urls
    )
  end

  def enqueue_job(job_id, urls)
    SearchgovIndexURLsJob.perform_later(job_id, urls)
  end
end
