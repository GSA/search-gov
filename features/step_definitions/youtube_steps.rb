Given(/^the following YouTube usernames exist for the site "(.*?)":$/) do |site_name, table|
  site = Affiliate.find_by_name(site_name)
  table.hashes.each do |hash|
    profile = YoutubeProfile.where(hash).first_or_initialize
    profile.save!
    site.youtube_profiles << profile
  end
end
