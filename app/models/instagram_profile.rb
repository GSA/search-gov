class InstagramProfile < ActiveRecord::Base
  has_and_belongs_to_many :affiliates

  validates_presence_of :id, :username
  validates_uniqueness_of :id

  def self.attributes_protected_by_default # allows us to set Instagram id as id
    super - ['id']
  end
end
