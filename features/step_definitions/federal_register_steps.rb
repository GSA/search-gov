Given /^the following "([^\"]*)" Federal Register Document entries exist:$/ do |federal_register_agency_short_name, table|
  federal_register_agency = FederalRegisterAgency.find_by_short_name federal_register_agency_short_name
  table.hashes.each do |attributes|
    document = FederalRegisterDocument.where(document_number: attributes[:document_number]).first_or_initialize
    document.assign_attributes attributes.except('document_number')
    document.federal_register_agency_ids = [federal_register_agency.id]
    document.save!
  end
  ElasticFederalRegisterDocument.commit
end
