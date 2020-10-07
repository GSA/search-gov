# frozen_string_literal: true

class ClickedController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    click = Click.new(click_params)

    if click.valid?
      click.log
      head :ok
    else
      render json: click.errors.full_messages, status: :bad_request
    end
  end

  private

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
      client_ip: request.env['REMOTE_ADDR'],
      user_agent: request.env['HTTP_USER_AGENT'],
      referrer: request.env['HTTP_REFERER']
    )
  end
end
