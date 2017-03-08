class FederalRegisterDocumentLoader
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.perform(federal_register_agency_id)
    fr_agency = FederalRegisterAgency.find_by_id federal_register_agency_id
    FederalRegisterDocumentData.load_documents fr_agency, load_all: true
  end
end
