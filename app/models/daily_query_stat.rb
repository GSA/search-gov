class DailyQueryStat < ActiveRecord::Base
  extend AttributeSquisher
  validates_presence_of :day, :query, :times, :affiliate
  validates_uniqueness_of :query, :scope => [:day, :affiliate]
  before_validation_squish :query

  class << self
    def sum_for_affiliate_between_dates(affiliate_name, start_date, end_date)
      DailyQueryStat.where('affiliate = ? AND day BETWEEN ? AND ?',
                           affiliate_name,
                           start_date,
                           end_date).sum(:times)
    end
  end
end
