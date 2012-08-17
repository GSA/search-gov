require 'action_dispatch/routing/route_set'
# Based on https://gist.github.com/2830082
module ActionDispatch
  module Routing
    class RouteSet
      class Dispatcher
        def call_with_invalid_char_handling(env)
          if env["REQUEST_URI"]
            uri = CGI::unescape(env["REQUEST_URI"].force_encoding("UTF-8"))
            # If anything in the REQUEST_URI has an invalid encoding, then raise since it's likely to trigger errors further on.
            return [400, {'X-Cascade' => 'pass'}, []] if uri.is_a?(String) and !uri.valid_encoding?
          end
          call_without_invalid_char_handling(env)
        end

        alias_method_chain :call, :invalid_char_handling
      end
    end
  end
end