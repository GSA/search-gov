class ExcludedUrl < ActiveRecord::Base
  validates_presence_of :url, :affiliate_id
  validates_uniqueness_of :url, :scope => :affiliate_id
  belongs_to :affiliate
end
