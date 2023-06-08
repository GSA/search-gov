module Instrumentation
  class LogSubscriber < ActiveSupport::LogSubscriber
    # The only methods that work as of 2023 are oasis_search and elastic_search. The others
    # should be removed when we remove those old search classes. The Bing methods need to
    # be updated to support BingV7.
    def azure_web_engine(event)
      generic_logging('Azure Query', event, BLUE)
    end

    def hosted_azure_web_engine(event)
      generic_logging('Hosted Azure Query', event, BLUE)
    end

    def bing_image_search(event)
      generic_logging('Bing Image Query', event, YELLOW)
    end

    def bing_web_search(event)
      generic_logging('Bing Query', event, YELLOW)
    end

    def oasis_search(event)
      generic_logging('Oasis Query', event, CYAN)
    end

    def elastic_search(event)
      generic_logging("#{event.payload[:index]} Query", event, MAGENTA)
    end

    private

    def generic_logging(label, event, color)
      name = format('%s (%.1fms)', label, event.duration)
      # The Redactor redacts strings matching certain patterns, such as 9-digit numbers
      # resembling SSNs. For Elasticsearch queries, it may redact false positives such
      # as 9-digit IDs. We may need to fine-tune the redaction if it is redacting too much
      # necessary information from the logs.
      query = Redactor.redact(event.payload[:query])
      info "  #{color(name, color, true)}  #{query}"
    end
  end
end

Instrumentation::LogSubscriber.attach_to(:usasearch)

ActiveSupport::Notifications.subscribe('request.faraday') do |_name, start_time, end_time, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = end_time - start_time
  Rails.logger.info(format('[%s] %s %s (%.3f s)', url.host, http_method, url.request_uri, duration))
end
