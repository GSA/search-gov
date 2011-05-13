class MonthlyPopularQuery < ActiveRecord::Base
  validates_presence_of :year, :month, :query, :times
  validates_uniqueness_of :query, :scope => [:year, :month, :is_grouped]
end
