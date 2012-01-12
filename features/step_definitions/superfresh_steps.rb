When /^the MSNbot visits the superfresh feed$/ do
  page.driver.header "User-Agent", SuperfreshUrl::MSNBOT_USER_AGENT
  visit main_superfresh_feed_path
end

Given /^the following SuperfreshUrls exist:$/ do |table|
  table.hashes.each do |hash|
    SuperfreshUrl.create(:url => hash["url"], :affiliate => Affiliate.find_by_name(hash["affiliate"]))
  end
end

Given /^the following IndexedDocuments exist:$/ do |table|
  ActiveRecord::Observer.disable_observers
  table.hashes.each do |hash|
    IndexedDocument.create!(:title => hash[:title],
                            :description => hash[:description],
                            :url => hash[:url],
                            :affiliate => Affiliate.find_by_name(hash[:affiliate]),
                            :last_crawled_at => hash[:last_crawled_at],
                            :last_crawl_status => hash[:last_crawl_status])
  end
  Sunspot.commit
  ActiveRecord::Observer.enable_observers
end

When /^the url "([^\"]*)" has been crawled$/ do |url|
  idoc = IndexedDocument.find_by_url(url)
  title = idoc.title.blank? ? 'some title' : idoc.title
  description = idoc.description.blank? ? 'some description' : idoc.description
  idoc.update_attributes!(:title => title,
                          :description => description,
                          :last_crawled_at => Time.now,
                          :last_crawl_status => IndexedDocument::OK_STATUS)
end

When /^there are (\d+) uncrawled IndexedDocuments for "([^"]*)"$/ do |count, aff_name|
  affiliate = Affiliate.find_by_name(aff_name)
  count.to_i.times do |index|
    affiliate.indexed_documents.create!(:title => "uncrawled document #{index + 1}",
                                        :description => "uncrawled document description #{index + 1}",
                                        :url => "http://aff.gov/uncrawled/#{index + 1}")
  end
end

When /^there are (\d+) crawled IndexedDocuments for "([^"]*)"$/ do |count, aff_name|
  affiliate = Affiliate.find_by_name(aff_name)
  count.to_i.times do |index|
    affiliate.indexed_documents.create!(:title => "crawled document #{index + 1}",
                                        :description => "crawled document description #{index + 1}",
                                        :url => "http://aff.gov/crawled/#{index + 1}",
                                        :last_crawled_at => Time.current,
                                        :last_crawl_status => 'OK')
  end
end
