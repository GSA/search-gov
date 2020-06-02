class ClickedController < ApplicationController
  def index
    url = CGI.unescape(params['url']).tr(' ', '+') rescue nil
    click = ClickSerp.new(url: url,
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
