Given /^the following Federal Register Document entries exist:$/ do |table|
  table.hashes.each do |attributes|
    fr_agency_short_names = attributes[:federal_register_agencies].split(/\s*,\s*/)
    fr_agency_ids = FederalRegisterAgency.where(short_name: fr_agency_short_names).pluck(:id)

    document = FederalRegisterDocument.where(document_number: attributes[:document_number]).first_or_initialize
    document.assign_attributes attributes.except(*%w(comments_close_in_days document_number federal_register_agencies))
    document.comments_close_on = Date.current.advance(days: attributes[:comments_close_in_days].to_i) if attributes[:comments_close_in_days].present?
    document.federal_register_agency_ids = fr_agency_ids
    document.save!
  end
  ElasticFederalRegisterDocument.commit
end
