# frozen_string_literal: true

class ClickedController < ApplicationController
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

  def click_params
    permitted = params.permit(:url, :query, :position,
                              :module_code, :affiliate, :vertical)
    permitted.to_hash.symbolize_keys.merge(client_ip: request.env['REMOTE_ADDR'],
                                           user_agent: request.env['HTTP_USER_AGENT'])
  end
end
