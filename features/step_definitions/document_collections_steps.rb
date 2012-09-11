Given /^affiliate "([^"]*)" has the following document collections:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    collection = affiliate.document_collections.create!(:name => hash[:name])
    prefixes = hash[:prefixes].split(',')
    prefixes.each do |prefix|
      collection.url_prefixes.create!(:prefix => prefix)
    end
    collection.navigation.update_attributes!(:is_active => hash[:is_navigable] || false,
                                             :position => hash[:position] || 100)
  end
end
