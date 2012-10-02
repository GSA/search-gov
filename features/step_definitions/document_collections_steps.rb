Given /^affiliate "([^"]*)" has the following document collections:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    collection = affiliate.document_collections.new(:name => hash[:name], :scope_keywords => hash[:scope_keywords])
    prefixes = hash[:prefixes].split(',')
    prefixes.each do |prefix|
      collection.url_prefixes.build(:prefix => prefix)
    end
    collection.save!
    collection.navigation.update_attributes!(:is_active => hash[:is_navigable] || false,
                                             :position => hash[:position] || 100)
  end
end
