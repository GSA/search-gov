class DailyClickStat < ActiveRecord::Base
  validates_presence_of :affiliate, :day, :url, :times
  validates_uniqueness_of :url, :scope => [:affiliate, :day]
end
