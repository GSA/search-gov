When(/^the following flickr URLs exist for the site "(.*)":$/) do |site_name, table|
  site = Affiliate.find_by_name(site_name)
  table.hashes.each do |hash|
    site.flickr_profiles.create!(hash)
  end
end
