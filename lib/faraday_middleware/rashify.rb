# frozen_string_literal: true

module FaradayMiddleware
  class Rashify < Faraday::Middleware
    def on_complete(env)
      env[:body] = FaradayResponseBodyRashify.parse(env[:body])
    end
  end
end
