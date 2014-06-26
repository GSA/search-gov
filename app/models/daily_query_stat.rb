class DailyQueryStat < ActiveRecord::Base
  extend AttributeSquisher
  validates_presence_of :day, :query, :times, :affiliate
  validates_uniqueness_of :query, :scope => [:day, :affiliate]
  before_validation_squish :query
end
