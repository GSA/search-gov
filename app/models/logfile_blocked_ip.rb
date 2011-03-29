class LogfileBlockedIp < ActiveRecord::Base
  validates_presence_of :ip
  validates_uniqueness_of :ip
end
