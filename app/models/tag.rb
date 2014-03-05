class Tag < ActiveRecord::Base
  extend AttributeSquisher

  before_validation_squish :name

  attr_accessible :name
  has_and_belongs_to_many :affiliate
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
end
