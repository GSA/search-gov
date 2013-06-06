class DowncaseRoute
  def initialize(app)
    @app = app
  end

  def call(env)
    env['PATH_INFO'] = env['PATH_INFO'].downcase unless env['PATH_INFO'] =~ /\.(css|gif|png|jpg|js)\Z/i
    @app.call(env)
  end
end
