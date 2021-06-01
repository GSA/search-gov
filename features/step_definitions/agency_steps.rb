Given "the following Agencies exist:" do |table|
  table.hashes.each do |hash|
    organization_codes = hash.delete('organization_codes').split(',')
    agency = Agency.new(hash)
    organization_codes.each do |code|
      agency.agency_organization_codes <<  AgencyOrganizationCode.new(organization_code: code)
    end
    agency.save!
  end
end
