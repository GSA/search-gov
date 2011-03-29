class LogfileBlockedQuery < ActiveRecord::Base
  validates_presence_of :query
  validates_uniqueness_of :query
end
