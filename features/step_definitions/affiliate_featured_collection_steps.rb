Given /^the following featured collections exist for the affiliate "([^"]*)":$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each_with_index do |hash, index|
    publish_start_on = hash['publish_start_on']
    publish_start_on = Date.current.send(publish_start_on.to_sym) if publish_start_on.present? and publish_start_on =~ /^[a-zA-Z]*$/

    publish_end_on = hash['publish_end_on']
    publish_end_on = Date.current.send(publish_end_on.to_sym) if publish_end_on.present? and publish_end_on =~ /^[a-zA-Z]*$/

    featured_collection = affiliate.featured_collections.build(:title => hash['title'],
                                                               :title_url => hash['title_url'],
                                                               :description => hash['description'],
                                                               :locale => hash['locale'],
                                                               :status => hash['status'],
                                                               :layout => hash['layout'] || 'one column',
                                                               :publish_start_on => publish_start_on,
                                                               :publish_end_on => publish_end_on,
                                                               :image_file_name => hash['image_file_name'] || 'image.jpg',
                                                               :image_content_type => hash['image_content_type'] || 'image/jpeg',
                                                               :image_file_size => hash['image_file_size'] || 50000,
                                                               :image_updated_at => DateTime.current,
                                                               :image_alt_text => hash['image_alt_text'],
                                                               :image_attribution => hash['image_attribution'],
                                                               :image_attribution_url => hash['image_attribution_url'])
    featured_collection.featured_collection_keywords.build(:value => "keyword value #{index + 1}")
    featured_collection.save!
  end
end

Then /^I should see "([^"]*)" featured collections$/ do |count|
  page.should have_selector(".featured-collection-list .row-item", :count => count)
end

Then /^the following featured collection keywords exist for featured collection titled "([^"]*)":$/ do |featured_collection_title, table|
  featured_collection = FeaturedCollection.find_by_title(featured_collection_title)
  featured_collection.featured_collection_keywords.delete_all
  table.hashes.each do |hash|
    featured_collection.featured_collection_keywords.create!(:value => hash['value'])
  end
end

Given /^there are (\d+) featured collections exist for the affiliate "([^"]*)":$/ do |count, affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each do |hash|
    count.to_i.times do |i|
      featured_collection = affiliate.featured_collections.build(
          :title => hash['title'] || "random title #{i + 1}",
          :title_url => hash['title_url'] || "http://example/random_content#{i + 1}.html",
          :locale => hash['locale'],
          :status => hash['status'] || "active",
          :layout => hash['layout'] || 'one column')
      featured_collection.featured_collection_keywords.build(:value => "keyword value #{i + 1}")
      featured_collection.save!
    end
  end
end

Given /^the following featured collection links exist for featured collection titled "([^"]*)":$/ do |featured_collection_title, table|
  featured_collection = FeaturedCollection.find_by_title(featured_collection_title)
  table.hashes.each_with_index do |hash, i|
    featured_collection.featured_collection_links.create!(:title => hash['title'], :url => hash['url'], :position => i)
  end
end

Given /^all featured collections are indexed$/ do
  FeaturedCollection.reindex
end
