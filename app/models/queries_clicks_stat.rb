class QueriesClicksStat < ActiveRecord::Base
  validates_presence_of :affiliate, :query, :day, :url, :times
  validates_uniqueness_of :url, :scope => [:affiliate, :query, :day], :case_sensitive => false

  class << self
    def top_urls(affiliate_name, query, start_date, end_date)
      sum(:times, :group => :url, :order => "sum_times desc",
          :conditions => ['day between ? AND ? AND affiliate = ? and query = ?', start_date, end_date, affiliate_name, query])
    end

    def top_queries(affiliate_name, url, start_date, end_date)
      sum(:times, :group => :query, :order => "sum_times desc",
          :conditions => ['day between ? AND ? AND affiliate = ? and url = ?', start_date, end_date, affiliate_name, url])
    end
  end
end
