Given /^the following featured collections exist for the affiliate "([^"]*)":$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each do |hash|
    FeaturedCollection.create!(:affiliate => affiliate,
                               :title => hash['title'],
                               :title_url => hash['title_url'],
                               :locale => hash['locale'],
                               :status => hash['status'])
  end
end

Then /^I should see "([^"]*)" featured collections$/ do |count|
  page.should have_selector(".featured-collection-list .row-item", :count => count)
end

Then /^the following featured collection keywords exist for featured collection titled "([^"]*)":$/ do |featured_collection_title, table|
  featured_collection = FeaturedCollection.find_by_title(featured_collection_title)
  table.hashes.each do |hash|
    featured_collection.featured_collection_keywords.create!(:value => hash['value'])
  end
end
