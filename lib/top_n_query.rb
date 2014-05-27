class TopNQuery
  include AffiliateMinusSpiderFilter

  def initialize(affiliate_name, agg_options = {})
    @affiliate_name = affiliate_name
    @agg_options = agg_options
  end

  def body
    Jbuilder.encode do |json|
      filter(json)
      terms_agg(json)
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
