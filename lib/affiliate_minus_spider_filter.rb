module AffiliateMinusSpiderFilter
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
    json.must do
      json.term { json.affiliate @affiliate_name }
    end
    json.must_not do
      json.term { json.set! "useragent.device", "Spider" }
    end
  end

end
