class DailyPopularQuery < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :day, :query, :times, :time_frame
  validates_uniqueness_of :query, :scope => [:day, :affiliate_id, :is_grouped, :time_frame]
  
  class << self
    
    def most_recent_populated_date(affiliate = nil, locale = I18n.default_locale.to_s)
      conditions = affiliate.nil? ? ["ISNULL(affiliate_id) AND locale=?", locale] : ["affiliate_id=? AND locale=?", affiliate.id, locale]
      maximum(:day, :conditions => conditions)
    end
  end
end
