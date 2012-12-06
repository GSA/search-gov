Given /^the following excluded site domains exist for the affiliate (.*):$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each do |hash|
    affiliate.excluded_domains.create!(:domain => hash[:domain])
  end
end
