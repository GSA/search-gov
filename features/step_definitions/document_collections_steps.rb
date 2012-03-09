Given /^affiliate "([^"]*)" has a result source of "([^"]*)"$/ do |affiliate_name, results_source|
  Affiliate.find_by_name(affiliate_name).update_attribute(:results_source, results_source)
end

Given /^affiliate "([^"]*)" has the following document collections:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    collection = affiliate.document_collections.create!(:name => hash[:name], :is_navigable => hash[:is_navigable] || false, :position => hash[:position])
    prefixes = hash[:prefixes].split(',')
    prefixes.each do |prefix|
      collection.url_prefixes.create!(:prefix => prefix)
    end
  end
end
