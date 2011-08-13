class LogfileBlockedUserAgent < ActiveRecord::Base
  validates_presence_of :agent
  validates_uniqueness_of :agent
end
