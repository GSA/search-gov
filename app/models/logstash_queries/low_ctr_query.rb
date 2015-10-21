class LowCtrQuery < DateRangeTopNExistsQuery
  def initialize(affiliate_name, start_date, end_date, agg_options = {})
    super(affiliate_name, start_date, end_date, agg_options.reverse_merge(min_doc_count: 20, size: 100000, field: 'raw'))
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      terms_agg(json, @agg_options) do
        json.aggs do
          json.ctr do
            json.scripted_metric do
              json.init_script "_agg['click'] = _agg['search'] = 0"
              json.map_script "_agg[doc['type'].value] += 1"
              json.reduce_script "clicks = searches = 0; for (agg in _aggs) {  clicks += agg.click ; searches += agg.search ;}; float ctr = searches == 0 ? 0 : 100 * clicks / searches; ctr"
            end
          end
        end
      end
    end
  end

end
