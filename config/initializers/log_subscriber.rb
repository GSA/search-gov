module Instrumentation
  class LogSubscriber < ActiveSupport::LogSubscriber
    def bing_search(event)
      generic_logging("Bing Query", event, YELLOW)
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
