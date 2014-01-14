class Status < ActiveRecord::Base
  BASE_STATUS_IDS = [1, 2].freeze
  extend AutoSquishAttributes
  auto_squish_attributes :name

  attr_accessible :name
  has_many :affiliates
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  def authorized_for_delete?
    return true unless BASE_STATUS_IDS.include?(id)
  end
end
