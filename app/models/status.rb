class Status < ActiveRecord::Base
  before_validation do |record|
    AttributeProcessor.squish_attributes record, :name
  end

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
