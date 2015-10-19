class LowCtrQuery < DateRangeTopNExistsQuery
  def initialize(options)
    start_date, end_date = "{{ctx.trigger.scheduled_time}}||-#{options[:time_window]}", "{{ctx.trigger.scheduled_time}}"
    @query_blocklist = options[:query_blocklist]
    super(options[:affiliate_name], start_date, end_date, options.slice(:min_doc_count).merge(size: 100000, field: "raw"))
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

  def additional_must_nots(json)
    super(json)
    json.child! do
      json.terms do
        json.raw query_blocklist_array
      end
    end if @query_blocklist.present?
  end

  private

  def query_blocklist_array
    @query_blocklist.split(',').map { |term| term.strip.downcase }
  end

end