module DateRangeFilter

  def date_range(json, field, start_date, end_date)
    json.range do
      json.set! field do
        json.gte start_date
        json.lte end_date
      end
    end
  end

  def must_affiliate_date_range(json, site_name, field, start_date, end_date)
    json.must do
      json.child! { json.term { json.affiliate site_name } }
      json.child! { date_range(json, field, start_date, end_date) }
    end
    json.must_not do
      json.term { json.set! "useragent.device", "Spider" }
    end
  end
end
