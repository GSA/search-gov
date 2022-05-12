class Agency < ApplicationRecord
  before_validation do |record|
    AttributeProcessor.squish_attributes record,
                                         :name,
                                         assign_nil_on_blank: true
  end
  validates_presence_of :name
  belongs_to :federal_register_agency
  has_many :agency_organization_codes, -> { order 'organization_code ASC' },
           dependent: :destroy, inverse_of: :agency
  has_many :affiliates
  after_save :load_federal_register_documents

  NAME_QUERY_PREFIXES = ["the", "us", "u.s.", "united states"]

  def friendly_name
    @friendly_name ||= begin
      friendly_name_str = name
      friendly_name_str << " FRA: #{federal_register_agency.to_label}" if federal_register_agency
      friendly_name_str << " JOBS: #{joined_organization_codes}" if agency_organization_codes.any?
      friendly_name_str
    end
  end

  def joined_organization_codes(separator = ';')
    agency_organization_codes.collect(&:organization_code).join(separator)
  end

  private

  def load_federal_register_documents
    federal_register_agency.load_documents if federal_register_agency
  end
end
