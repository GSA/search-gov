module Turbolinks
  module Cookies
    private
    def set_request_method_cookie
      cookies[:request_method] = {
        value: request.request_method,
        secure: Rails.application.config.ssl_options[:secure_cookies]
      }
    end
  end
end
