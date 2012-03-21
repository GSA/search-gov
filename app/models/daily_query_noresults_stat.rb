class DailyQueryNoresultsStat < ActiveRecord::Base
  validates_presence_of :day, :query, :times, :affiliate
  validates_uniqueness_of :query, :scope => [:day, :affiliate]

  def self.most_popular_no_results_queries(start_date, end_date, num_results, affiliate_name)
    sum(:times,
        :group => :query,
        :conditions => ['day between ? AND ? AND affiliate = ?', start_date, end_date, affiliate_name],
        :order => "sum_times desc",
        :limit => num_results).
      collect { |hash| QueryCount.new(hash.first, hash.last) }
  end
end
