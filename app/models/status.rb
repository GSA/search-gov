class Status < ActiveRecord::Base
  extend AttributeSquisher

  before_validation_squish :name

  BASE_STATUS_IDS = [1, 2].freeze
  INACTIVE_DELETED_NAME = 'inactive - deleted'.freeze

  attr_accessible :name
  has_many :affiliates
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  def authorized_for_delete?
    return true unless BASE_STATUS_IDS.include?(id)
  end

  def inactive_deleted?
    name == INACTIVE_DELETED_NAME
  end
end
