class DailyQueryNoresultsStat < ActiveRecord::Base
  validates_presence_of :day, :query, :times, :affiliate
  validates_uniqueness_of :query, :scope => [:day, :affiliate]
end
