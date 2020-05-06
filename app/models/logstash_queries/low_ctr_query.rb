# frozen_string_literal: true

class LowCtrQuery < DateRangeTopNExistsQuery
  def initialize(affiliate_name, start_date, end_date, agg_options = {})
    super(affiliate_name,
          %w[search click],
          start_date,
          end_date,
          agg_options.reverse_merge(min_doc_count: 20,
                                    size: 100_000,
                                    field: 'params.query.raw'))
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      terms_agg(json, @agg_options) do
        json.aggs do
          json.ctr do
            json.scripted_metric do
              json.init_script { json.source init_script }
              json.map_script { json.source map_script }
              json.reduce_script { json.source reduce_script }
            end
          end
        end
      end
    end
  end

  private

  def init_script
    "params._agg['click'] = params._agg['search'] = 0"
  end

  def map_script
    "params._agg[doc['type'].value] += 1"
  end

  def reduce_script
    <<~SCRIPT.strip
      int clicks = 0;
      int searches = 0;
      for (agg in params._aggs){
        clicks += agg.click ;
        searches += agg.search
      }
      double ctr = searches == 0 ? 0 : 100.0 * clicks / searches; ctr
    SCRIPT
  end
end
