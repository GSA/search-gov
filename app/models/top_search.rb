class TopSearch < ActiveRecord::Base
  validates_presence_of :position, :query
  validates_numericality_of :position, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5
  
  def link_url
    self.url.present? ? self.url : "http://search.usa.gov/search?query=#{CGI::escape(self.query)}&linked=1&position=#{self.position}"
  end
end
