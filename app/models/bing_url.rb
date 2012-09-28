class BingUrl < ActiveRecord::Base
  validates_presence_of :normalized_url
  validates_uniqueness_of :normalized_url
  attr_readonly :normalized_url
end