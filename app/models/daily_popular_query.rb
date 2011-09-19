class DailyPopularQuery < ActiveRecord::Base
  @queue = :usasearch

  belongs_to :affiliate
  validates_presence_of :day, :query, :times, :time_frame
  validates_uniqueness_of :query, :scope => [:day, :affiliate_id, :is_grouped, :time_frame]

  class << self

    def most_recent_populated_date(affiliate = nil, locale = I18n.default_locale.to_s)
      conditions = affiliate.nil? ? ["ISNULL(affiliate_id) AND locale=?", locale] : ["affiliate_id=? AND locale=?", affiliate.id, locale]
      maximum(:day, :conditions => conditions)
    end

    def calculate(day, time_frame, method, is_grouped)
      Resque.enqueue(DailyPopularQuery, day, time_frame, method, is_grouped)
      Affiliate.all.each {|affiliate| Resque.enqueue(DailyPopularQuery, day, time_frame, method, is_grouped, affiliate.id) } unless is_grouped
    end

    def perform(day_string, time_frame, method, is_grouped, affiliate_id = nil)
      day = Date.parse(day_string)
      delete_all(["day = ? and time_frame = ? and is_grouped = ? and affiliate_id = ?", day, time_frame, is_grouped, affiliate_id])
      affiliate_name = affiliate_id.nil? ? Affiliate::USAGOV_AFFILIATE_NAME : Affiliate.find(affiliate_id).name
      query_counts = DailyQueryStat.send(method, day, time_frame, 1000, affiliate_name)
      query_counts.each do |query_count|
        create!(:day => day, :affiliate_id => affiliate_id, :locale => 'en', :query => query_count.query,
                :is_grouped => is_grouped, :time_frame => time_frame, :times => query_count.times)
      end unless query_counts.is_a?(String)
    end
  end
end