# frozen_string_literal: true

# If we ever need more complex logic, or to include this our other apps, we should
# move it to a gem: https://github.com/lostisland/faraday/blob/main/docs/middleware/custom.md
class FaradayMiddleware::ExceptionNotifier < Faraday::Middleware
  attr_reader :tags

  def initialize(app, tags = [])
    super(app)
    @tags = tags
  end

  def call(env)
    @app.call(env)
  rescue Faraday::ClientError => e
    ExceptionNotifier.notify_exception(e, tags: tags)
    raise
  end
end
