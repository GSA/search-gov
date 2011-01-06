class PopularImageQuery < ActiveRecord::Base
  validates_uniqueness_of :query
  validates_presence_of :query
end
