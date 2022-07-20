# frozen_string_literal: true

class ClickedController < ApplicationController
  skip_before_action :verify_authenticity_token

  attr_reader :click

  def create
    @click = click_class.new(click_params)

    if click.valid?
      click.log
      head :ok
    else
      render json: click.errors.full_messages, status: invalid_click_status
    end
  end

  private

  def click_class
    Click
  end

  def permitted_params
    params.permit(
      :url,
      :query,
      :position,
      :module_code,
      :affiliate,
      :vertical
    )
  end

  def click_params
    permitted_params.to_hash.symbolize_keys.merge(
      client_ip: request.remote_ip,
      user_agent: request.user_agent,
      referrer: request.referer
    )
  end

  def invalid_click_status
    :bad_request
  end
end
