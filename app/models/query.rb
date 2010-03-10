class Query < ActiveRecord::Base
  validates_presence_of :ipaddr
  validates_presence_of :timestamp
  validates_presence_of :affiliate
  validates_presence_of :locale
end
