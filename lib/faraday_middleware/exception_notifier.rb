# frozen_string_literal: true

module FaradayMiddleware
  class ExceptionNotifier < Faraday::Middleware
    attr_reader :tags

    def initialize(app, tags = [])
      super(app)
      @tags = tags
    end

    def call(env)
      @app.call(env)
    rescue Faraday::Error => e
      ::ExceptionNotifier.notify_exception(e, tags: tags)
      raise
    end
  end
end
