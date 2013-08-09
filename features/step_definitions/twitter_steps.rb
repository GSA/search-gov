When(/^the following Twitter handles exist for the site "(.*?)":$/) do |site_name, table|
  site = Affiliate.find_by_name(site_name)
  table.hashes.each do |hash|
    profile = TwitterProfile.where(hash).first_or_initialize
    profile.save!
    site.twitter_profiles << profile
  end
end
