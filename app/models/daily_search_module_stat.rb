class DailySearchModuleStat < ActiveRecord::Base
  require "ostruct"
  validates_presence_of :day, :locale, :affiliate_name, :vertical, :module_tag, :clicks, :impressions
  validates_uniqueness_of :module_tag, :scope => [:day, :affiliate_name, :locale, :vertical]
  belongs_to :search_module, :primary_key => "tag", :foreign_key => "module_tag", :class_name => "SearchModule"

  def self.most_recent_populated_date
    maximum(:day)
  end

  def self.module_stats_for_daterange(daterange)
    results = select('module_tag, SUM(clicks) AS clicks, SUM(impressions) AS impressions').includes(:search_module).
      where(:day => daterange).group(:module_tag).order("impressions DESC")
    return [] if results.nil?
    structs = results.collect do |stat|
      OpenStruct.new(:display_name => stat.search_module.display_name, :clicks => stat.clicks, :impressions => stat.impressions,
                     :clickthru_ratio => 100.0 * stat.clicks / stat.impressions) unless stat.search_module.nil?
    end
    structs.compact
  end
end