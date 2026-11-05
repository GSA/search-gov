# frozen_string_literal: true

module FaradayMiddleware
  class Rashify < Faraday::Middleware
    def on_complete(env)
      env[:body] = case env[:body]
                   when Hash
                     FaradayResponseBodyRashify.parse(env[:body])
                   when String
                     FaradayResponseBodyRashify.parse(::JSON.parse(env[:body]))
                   else
                     env[:body]
                   end
    rescue JSON::ParserError
      env[:body]
    end
  end
end
