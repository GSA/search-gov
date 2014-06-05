Given /^the following FlickrPhotos exist:$/ do |table|
  flickr_id = 100
  table.hashes.each do |hash|
    affiliate = Affiliate.find_by_name(hash[:affiliate_name])
    flickr_url = 'https://www.flickr.com/photos/whitehouse'
    flickr_profile = affiliate.flickr_profiles.where(url: flickr_url).first_or_create!
    flickr_id += 1
    photo_attributes = hash.except('affiliate_name').merge(flickr_id: flickr_id)
    flickr_profile.flickr_photos.create! photo_attributes
  end
  ElasticFlickrPhoto.commit
end

Given /^there are (\d+) flickr photos for "([^\"]*)" with title prefix "([^\"]*)"$/ do |count, affiliate_name, title_prefix|
  affiliate = Affiliate.find_by_name affiliate_name
  flickr_url = 'https://www.flickr.com/photos/whitehouse'
  flickr_profile = affiliate.flickr_profiles.where(profile_id: '35591378@N03',
                                                   url: flickr_url).first_or_create!

  flickr_id = 100
  count.to_i.times do |i|
    flickr_profile.flickr_photos.create!(flickr_id: flickr_id + i,
                                         title: "#{title_prefix} photo #{i}",
                                         url_q: "http://farm9.staticflickr.com/#{i + 1}/#{i + 1}_q.jpg")
  end
  ElasticFlickrPhoto.commit
end
