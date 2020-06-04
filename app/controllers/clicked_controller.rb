# frozen_string_literal: true

class ClickedController < ApplicationController
  def index
    click = ClickSerp.new(url: params['url'],
                          query: params['query'],
                          affiliate: params['affiliate'].presence,
                          position: params['position'],
                          module_code: params['module_code'],
                          vertical: params['vertical'],
                          client_ip: request.env['REMOTE_ADDR'],
                          user_agent: request.env['HTTP_USER_AGENT'])

    if click.valid?
      click.log
      head :ok
    else
      render json: click.errors.full_messages, status: :bad_request
    end
  end
end
