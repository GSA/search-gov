class ExcludedUrl < ActiveRecord::Base
  validates_presence_of :url, :affiliate_id
  validates_uniqueness_of :url, :scope => :affiliate_id
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
  belongs_to :affiliate
end
