require 'mrashify'

Faraday::Response.register_middleware mrashify: FaradayMiddleware::MRashify
