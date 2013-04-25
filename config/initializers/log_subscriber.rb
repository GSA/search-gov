module Instrumentation
  class LogSubscriber < ActiveSupport::LogSubscriber
    def bing_search(event)
      generic_logging("Bing Query", event, YELLOW)
    end

    def google_search(event)
      generic_logging("Google Query", event, RED)
    end

    def solr_search(event)
      generic_logging("Solr Query", event, GREEN)
    end

    private
    def generic_logging(label, event, color)
      name = '%s (%.1fms)' % [label, event.duration]
      query = event.payload[:query].to_json
      info "  #{color(name, color, true)}  #{query}"
    end
  end
end

Instrumentation::LogSubscriber.attach_to :usasearch

ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = end_time - start_time
  Rails.logger.info('[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration])
end