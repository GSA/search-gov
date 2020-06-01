module Api
  module V2
    class ClickController < ApplicationController
      def create
        url = CGI.unescape(params['url']).gsub(' ', '+') rescue nil
        click = Click.new(url: url,
                          query: params['query'],
                          affiliate: params['affiliate'].presence,
                          access_key: params['access_key'],
                          position: params['position'],
                          module_code: params['module_code'],
                          vertical: params['vertical'],
                          client_ip: params['client_ip'],
                          user_agent: params['user_agent'])

        if click.valid?
          click.log
          head :ok
        else
          status_code = if click.errors.messages[:access_key] == ['is invalid']
                          :unauthorized
                        else
                          :bad_request
                        end
          render json: click.errors.full_messages, status: status_code
        end
      end
    end
  end
end
