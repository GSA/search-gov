module Turbolinks
  module Cookies
    private
    def set_request_method_cookie
      cookies[:request_method] = {
        value: request.request_method,
        secure: UsasearchRails3::Application.config.ssl_options[:secure_cookies]
      }
    end
  end
end
