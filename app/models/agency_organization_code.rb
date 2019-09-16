class AgencyOrganizationCode < ApplicationRecord
  DEPARTMENT_LEVEL_LENGTH = 2

  before_validation do |record|
    AttributeProcessor.squish_attributes record,
                                         :organization_code,
                                         assign_nil_on_blank: true
  end

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
