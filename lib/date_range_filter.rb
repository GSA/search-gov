module DateRangeFilter

  def date_range(json, field, start_date, end_date)
    json.range do
      json.set! field do
        json.gte start_date
        json.lte end_date
      end
    end
  end

end
