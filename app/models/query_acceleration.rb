class QueryAcceleration < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :query
  validates_presence_of :window_size
  validates_presence_of :score
  validates_uniqueness_of :query, :scope => [:day, :window_size]
  RESULTS_SIZE = 10

end
