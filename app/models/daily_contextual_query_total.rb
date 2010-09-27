class DailyContextualQueryTotal < ActiveRecord::Base
  validates_presence_of :day, :total
  validates_numericality_of :total
  validates_uniqueness_of :day
  before_validation :compute_total

  class << self
    def total_for(date)
      daily_contextual_query_total = find_by_day(date)
      daily_contextual_query_total.present? ? daily_contextual_query_total.total : 0
    end    
  end
  
  private 
  
  def compute_total
    self.total = Query.count(:all, :conditions => ["date(timestamp)=? AND is_contextual=? AND is_bot=?", self.day, true, false]) if self.total.nil?
    true
  end
end
