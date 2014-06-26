class OverallTopNQuery

  def initialize(since, agg_options = {})
    @since = since
    @agg_options = agg_options
  end

  def body
    Jbuilder.encode do |json|
      filter(json)
      terms_agg(json)
    end
  end

  def filter(json)
    json.query do
      json.filtered do
        json.filter do
          json.bool do
            booleans(json)
          end
        end
      end
    end
  end

  def booleans(json)
    json.must_not do
      json.term { json.tags 'api' }
    end
    json.must do
      json.range do
        json.set! '@timestamp' do
          json.gte @since
        end
      end
    end
  end

  def terms_agg(json)
    json.aggs do
      json.agg do
        json.terms do
          @agg_options.each do |option, value|
            json.set! option, value
          end
        end
      end
    end
  end
end
