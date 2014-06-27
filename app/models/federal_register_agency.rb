class FederalRegisterAgency < ActiveRecord::Base
  extend AttributeSquisher

  attr_accessible :id, :name, :short_name
  has_many :agencies
  before_validation_squish :name, :short_name, assign_nil_on_blank: true
  validates_presence_of :id, :name

  scope :active, joins(:agencies).uniq

  def to_label
    "#{name} (#{id})"
  end
end
