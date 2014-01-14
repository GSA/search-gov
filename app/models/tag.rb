class Tag < ActiveRecord::Base
  extend AutoSquishAttributes
  auto_squish_attributes :name

  attr_accessible :name
  has_and_belongs_to_many :affiliate
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
end
