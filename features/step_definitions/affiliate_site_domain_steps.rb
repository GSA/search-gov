Given /^the following site domains exist for the affiliate (.*):$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each do |hash|
    affiliate.site_domains.create!(:site_name => hash[:site_name], :domain => hash[:domain])
  end
end
