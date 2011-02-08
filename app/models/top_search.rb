class TopSearch < ActiveRecord::Base
  validates_presence_of :position
  validates_numericality_of :position, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5
  before_validation :set_query_to_nil_if_blank

  def self.find_active_entries
    all(:conditions => "query IS NOT NULL", :order => "position ASC", :limit => 5)
  end

  def link_url
    self.url.present? ? self.url : "http://search.usa.gov/search?query=#{CGI::escape(self.query)}&linked=1&position=#{self.position}"
  end

  private
  def set_query_to_nil_if_blank
    self.query = nil if self.query.blank?
  end
end
