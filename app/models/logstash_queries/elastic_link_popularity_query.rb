# frozen_string_literal: true

class ElasticLinkPopularityQuery
  def initialize(link, days_back = 7)
    @link = link
    @days_back = days_back
  end

  def body
    link = @link.sub(/\/$/, '')
    links = [link, "#{link}/"]
    Jbuilder.encode do |json|
      json.query do
        json.constant_score do
          json.filter do
            json.bool do
              json.must do
                json.child! do
                  json.terms do
                    json.set! 'params.url', links
                  end
                end
                json.child! do
                  json.range do
                    json.set! '@timestamp' do
                      json.gt "now-#{@days_back}d/d"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
