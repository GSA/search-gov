class TopSearch < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :position
  validates_uniqueness_of :position, :scope => :affiliate_id
  validates_numericality_of :position, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5
  before_validation :set_query_to_nil_if_blank

  def self.find_active_entries
    all(:conditions => "query IS NOT NULL AND affiliate_id IS NULL", :order => "position ASC", :limit => 5)
  end

  private
  
  def set_query_to_nil_if_blank
    self.query = nil if self.query.blank?
  end
end
