class AgencyOrganizationCode < ActiveRecord::Base
  DEPARTMENT_LEVEL_LENGTH = 2
  extend AttributeSquisher

  before_validation_squish :organization_code, assign_nil_on_blank: true

  validates_presence_of :organization_code, :agency
  validates_uniqueness_of :organization_code, case_sensitive: false, scope: :agency_id
  belongs_to :agency

  def to_label
    organization_code
  end

  def is_department_level?
    organization_code.length == DEPARTMENT_LEVEL_LENGTH
  end

end