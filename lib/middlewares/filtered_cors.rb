class FilteredCORS
  PATH_WITH_CORS_SUPPORT = %r{\A/(api/search|api/v2/search|sayt)}.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    status, headers, response = @app.call(env)

    if request.path_info =~ PATH_WITH_CORS_SUPPORT
      headers['Access-Control-Allow-Origin'] = '*'
    end

    [status, headers, response]
  end
end
