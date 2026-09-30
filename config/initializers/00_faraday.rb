# frozen_string_literal: true

require 'faraday'
require 'faraday/net_http_persistent'
require_relative '../../lib/faraday_middleware/exception_notifier'
require_relative '../../lib/faraday_middleware/rashify'

# elasticsearch-transport 7.4 still references Faraday 0 nested error constants.
module Faraday
  class Error
    ConnectionFailed = Faraday::ConnectionFailed unless const_defined?(:ConnectionFailed, false)
    TimeoutError = Faraday::TimeoutError unless const_defined?(:TimeoutError, false)
  end
end

Faraday::Response.register_middleware(rashify: FaradayMiddleware::Rashify)
