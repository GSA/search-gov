class LogfileWhitelistedClassC < ActiveRecord::Base
  validates_presence_of :classc
  validates_uniqueness_of :classc, :case_sensitive => false
end
