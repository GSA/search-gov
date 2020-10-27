# frozen_string_literal: true

# This class should eventually be replaced and its specs refactored
# in favor of configuration based on the rack-cors gem
class FilteredCORS
  PATH_WITH_CORS_SUPPORT = %r{\A/(api/search|api/v2/click|api/v2/search|sayt)}.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    status, headers, response = @app.call(env)

    if request.path_info.match? PATH_WITH_CORS_SUPPORT
      headers['Access-Control-Allow-Origin'] = '*'
    end

    [status, headers, response]
  end
end
