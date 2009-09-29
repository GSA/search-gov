class Timeline
  attr_accessor :series, :dates

  def initialize(query, grouped = nil)
    @series, @dates = [], []
    if grouped
      results = DailyQueryStat.collect_query_group_named(query)
    else
      results = DailyQueryStat.find_all_by_query(query, :order => "day", :select=>"day, times")
    end
    return if results.empty?
    date_marker = results.first.day
    pad_with_zeroes_from_to(Date.new(2009, 1, 1), date_marker - 1.day)
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
    pad_with_zeroes_from_to(date_marker, DailyQueryStat.most_recent_populated_date)
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
