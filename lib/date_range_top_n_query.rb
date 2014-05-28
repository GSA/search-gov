class DateRangeTopNQuery < TopNQuery
  def initialize(affiliate_name, start_date, end_date, agg_options = {})
    super(affiliate_name, agg_options)
    @start_date, @end_date = start_date, end_date
  end

  def booleans(json)
    json.must do
      json.child! { json.term { json.affiliate @affiliate_name } }
      json.child! { date_range(json) }
    end
  end

  def date_range(json)
    json.range do
      json.set! "@timestamp" do
        json.gte @start_date
        json.lte @end_date
      end
    end
  end

end