Given(/^the following YouTube channels exist for the site "(.*?)":$/) do |site_name, table|
  site = Affiliate.find_by_name(site_name)
  table.hashes.each do |hash|
    profile = YoutubeProfile.where(hash).first_or_initialize
    profile.save!
    site.youtube_profiles << profile
  end
  site.enable_video_govbox!
end
