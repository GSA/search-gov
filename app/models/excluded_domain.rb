class ExcludedDomain < ActiveRecord::Base
  validates_presence_of :domain
end
