class DailyClickStat < ActiveRecord::Base
  extend AffiliateDailyStats
  RESULTS_SIZE = 10
  validates_presence_of :affiliate, :day, :url, :times
  validates_uniqueness_of :url, :scope => [:affiliate, :day]

  class << self
    def top_urls(affiliate_name, start_date, end_date, num_results = RESULTS_SIZE)
      sum(:times, :group => :url, :order => "sum_times desc", :limit => num_results,
          :conditions => ['day between ? AND ? AND affiliate = ?', start_date, end_date, affiliate_name])
    end
  end
end
