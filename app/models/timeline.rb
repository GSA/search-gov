class Timeline
  DEFAULT_RANGE_IN_MONTHS = -13
  attr_accessor :series, :dates

  def self.load_affiliate_daily_query_stats(query, affiliate_name, start_date = Date.yesterday.advance(:months => DEFAULT_RANGE_IN_MONTHS))
    Timeline.new(query, nil, affiliate_name, start_date)
  end

  def initialize(query, grouped = nil, affiliate_name = nil, start_date = Date.yesterday.advance(:months => DEFAULT_RANGE_IN_MONTHS))
    @series, @dates = [], []
    if affiliate_name
      results = DailyQueryStat.collect_affiliate_query(query, affiliate_name, start_date)
    elsif grouped
      results = DailyQueryStat.collect_query_group_named(query, start_date)
    else
      results = DailyQueryStat.collect_query(query, start_date)
    end
    date_marker = results.first.present? ? results.first.day : Date.yesterday
    pad_with_zeroes_from_to(start_date, date_marker - 1.day)
    results.each do |dqs|
      while (dqs.day != date_marker)
        @series << Datum.new(:y => 0)
        @dates << date_marker
        date_marker += 1.day
      end
      @series << Datum.new( :y => dqs.times)
      @dates << dqs.day
      date_marker += 1.day
    end
    if affiliate_name
      most_recent_populated_date = DailyQueryStat.most_recent_populated_date affiliate_name
    else
      most_recent_populated_date = DailyQueryStat.most_recent_populated_date
    end
    pad_with_zeroes_from_to(date_marker, most_recent_populated_date) if most_recent_populated_date
  end

  private
  def pad_with_zeroes_from_to(from_date, to_date)
    return unless to_date >= from_date
    from_date.upto(to_date) do |day|
      @series << Datum.new(:y => 0)
      @dates << day
    end
  end

end
