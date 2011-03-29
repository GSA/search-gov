class LogfileBlockedRegexp < ActiveRecord::Base
  validates_presence_of :regexp
  validates_uniqueness_of :regexp
end
