class Timeline
  attr_accessor :series, :dates

  def initialize(query)
    @series = []
    results = DailyQueryStat.sum(:times, :group => :day, :order => "day", :conditions => ['query = ?', query])
    @dates = results.keys
    date_marker = @dates.first
    results.each_pair do |day, times|
      while (day != date_marker)
        @series << Datum.new(:y => 0)
        @dates << date_marker
        date_marker += 1.day
      end
      @series << Datum.new( :y => times)
      date_marker += 1.day
    end
    @dates.sort!
  end
end
