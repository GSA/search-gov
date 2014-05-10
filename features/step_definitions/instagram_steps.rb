Given(/^the following Instagram usernames exist for the site "(.*?)":$/) do |site_name, table|
  site = Affiliate.find_by_name site_name
  table.hashes.each do |hash|
    profile = InstagramProfile.where(hash).first_or_initialize
    profile.id ||= begin
      maximum_id = InstagramProfile.maximum(:id)
      maximum_id ||= 0
      maximum_id += 1
    end
    profile.save!
    site.instagram_profiles << profile
  end
end
