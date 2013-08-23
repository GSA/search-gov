When(/^the following Excluded URLs exist for the site "(.*?)":$/) do |site_name, table|
  site = Affiliate.find_by_name(site_name)
  table.hashes.each do |hash|
    site.excluded_urls.create! hash
  end
end
