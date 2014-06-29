module DateRangeFilter

  def must_affiliate_date_range(json, site_name, start_date, end_date)
    json.must do
      json.child! { json.term { json.affiliate site_name } }
      json.child! { date_range(json, start_date, end_date) }
    end
    json.must_not do
      json.term { json.set! "useragent.device", "Spider" }
    end
  end
end
