class FederalRegisterDocumentLoader
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(federal_register_agency_id)
    FederalRegisterDocumentData.load_documents federal_register_agency_ids: [federal_register_agency_id]
  end
end
