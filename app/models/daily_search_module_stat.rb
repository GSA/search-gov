class DailySearchModuleStat < ActiveRecord::Base
  validates_presence_of :day, :locale, :affiliate_name, :vertical, :module_tag, :clicks, :impressions
  validates_uniqueness_of :module_tag, :scope => [:day, :affiliate_name, :locale, :vertical]
  belongs_to :search_module, primary_key: "tag", foreign_key: "module_tag", class_name: "SearchModule"
  before_validation :set_locale

  def self.most_recent_populated_date_for(site_name)
    where(affiliate_name: site_name).maximum(:day)
  end

  def self.oldest_populated_date_for(site_name)
    where(affiliate_name: site_name).minimum(:day)
  end

  private

  def set_locale
    self.locale = (Affiliate.find_by_name(self.affiliate_name).locale rescue "en") unless self.locale
  end
end