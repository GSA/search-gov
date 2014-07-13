Given /^the following "([^\"]*)" Federal Register Document entries exist:$/ do |federal_register_agency_short_name, table|
  federal_register_agency = FederalRegisterAgency.find_by_short_name federal_register_agency_short_name
  table.hashes.each do |attributes|
    document = FederalRegisterDocument.where(document_number: attributes[:document_number]).first_or_initialize
    document.assign_attributes attributes.except('comments_close_in_days', 'document_number')
    document.comments_close_on = Date.current.advance(days: attributes[:comments_close_in_days].to_i)
    document.federal_register_agency_ids = [federal_register_agency.id]
    document.save!
  end
  ElasticFederalRegisterDocument.commit
end
