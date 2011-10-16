class DailyPopularQueryGroup < ActiveRecord::Base
  @queue = :usasearch

  validates_presence_of :query_group_name, :day, :times, :time_frame
  validates_uniqueness_of :query_group_name, :scope => [:day, :time_frame]

  class << self

    def calculate(day, time_frame)
      Resque.enqueue(DailyPopularQueryGroup, day, time_frame)
    end

    def perform(day_string, time_frame)
      day = Date.parse(day_string)
      delete_all(["day = ? and time_frame = ?", day, time_frame])
      query_counts = DailyQueryStat.most_popular_query_groups(day, time_frame, 1000, Affiliate::USAGOV_AFFILIATE_NAME)
      query_counts.each do |query_count|
        create!(:day => day, :query_group_name => query_count.query, :time_frame => time_frame, :times => query_count.times)
      end unless query_counts.is_a?(String)
    end

    def get_by_day_and_time_frame(day, time_frame, limit)
      find_all_by_day_and_time_frame(day, time_frame, :limit => limit, :order => 'times DESC').
        collect { |res| QueryCount.new(res.query_group_name, res.times, true) }
    end
  end
end