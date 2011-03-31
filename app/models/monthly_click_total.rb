class MonthlyClickTotal < ActiveRecord::Base
  validates_presence_of :year, :month, :source, :total
  validates_uniqueness_of :source, :scope => [:year, :month]
  validates_numericality_of :total, :greater_than_or_equal_to => 10
end
