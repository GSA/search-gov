# frozen_string_literal: true

require 'securerandom'

class UrlsController < ApplicationController
  skip_before_action :verify_authenticity_token
  wrap_parameters false

  attr_reader :urls

  def create
    uuid = SecureRandom.uuid
    urls = params[:urls]
    if urls.nil?
      render json: { error: "The 'urls' parameter is required." }.to_json, status: '422'
      return nil
    end
    enqueue_job(uuid, urls)
    response = {
      job_id: uuid
    }.to_json
    Rails.logger.info "'/urls': #{uuid} job added to the queue", total_count: urls.count
    render json: response, status: :ok
  end

  private

  def permitted_params
    params.permit(
      :urls
    )
  end

  def enqueue_job(job_id, urls)
    SearchgovUrlsJob.perform_later(job_id, urls)
  end
end
