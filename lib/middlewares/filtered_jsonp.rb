require 'rack/contrib/jsonp'

class FilteredJSONP < ::Rack::JSONP
  PATHS_WITH_JSONP_SUPPORT = %r{\A/(api/search|sayt)}i

  def call(env)
    request = Rack::Request.new(env)

    if request.path_info =~ PATHS_WITH_JSONP_SUPPORT
      super
    else
      @app.call(env)
    end
  end
end
