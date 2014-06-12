class AdjustClientIp
  def initialize(app)
    @app = app
  end

  def call(env)
    env['REMOTE_ADDR'] = env['HTTP_TRUE_CLIENT_IP'] if env['HTTP_TRUE_CLIENT_IP'].present?
    env.delete('HTTP_X_FORWARDED_FOR')
    @app.call(env)
  end
end