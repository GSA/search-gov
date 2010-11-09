class DailyContextualQueryTotal < ActiveRecord::Base
  validates_presence_of :day, :total
  validates_numericality_of :total
  validates_uniqueness_of :day

  class << self
    def total_for(date)
      daily_contextual_query_total = find_by_day(date)
      daily_contextual_query_total.present? ? daily_contextual_query_total.total : 0
    end
  end

end
