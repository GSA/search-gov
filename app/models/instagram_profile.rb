class InstagramProfile < ActiveRecord::Base
  attr_accessible :id, :username

  has_and_belongs_to_many :affiliates

  validates_presence_of :id, :username
  validates_uniqueness_of :id
end
