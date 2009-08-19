class Affiliate < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def domain_list
    return "" if self.domains.blank?
    self.domains.split("\n").collect { |name| "site:#{name.strip}"}.join(" OR ")   
  end
end
