class RejectInvalidRequestUri
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['REQUEST_URI']
      uri = begin
        CGI::unescape(env['REQUEST_URI'].force_encoding('UTF-8'))
      rescue ArgumentError
        nil
      end
      return [400, { 'Content-Type' => 'text/html', 'Content-Length' => '0' }, []] if uri.nil? || (uri.is_a?(String) and !uri.valid_encoding?)
    end
    @app.call(env)
  end
end