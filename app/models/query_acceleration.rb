class QueryAcceleration < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :query
  validates_presence_of :window_size
  validates_presence_of :score
  validates_uniqueness_of :query, :scope => [:day, :window_size]
  RESULTS_SIZE = 10

  def self.biggest_movers_over_window(window_size)
    results = QueryAcceleration.find_all_by_day_and_window_size(Date.yesterday.to_date, window_size, :order => "score desc", :limit => RESULTS_SIZE)
    results.empty? ? nil : results
  end

end
