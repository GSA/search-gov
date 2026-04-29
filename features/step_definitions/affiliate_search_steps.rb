Given /^there are (\d+)( manual| rss)? indexed documents for affiliate "([^"]*)"$/ do |count, source, affiliate|
  affiliate = Affiliate.find_by(name: affiliate)

  count.to_i.times do |index|
    IndexedDocument.create!(affiliate: affiliate,
                            title: "Document number #{index + 1}",
                            description: 'An Indexed Document',
                            url: "http://petitions.whitehouse.gov/petition-#{index + 1}.html",
                            source: source.strip,
                            last_crawl_status: 'OK',
                            last_crawled_at: Time.current.to_i)
  end
  ElasticIndexedDocument.commit
end

Then /^I should not see "([^"]*)" in bold font$/ do |text|
  page.should_not have_selector("strong", :text => text)
end

Then /^I should see "([^"]*)" in bold font$/ do |text|
  page.should have_selector("strong", :text => text)
end

Given /^the following Medline Topics exist:$/ do |table|
  table.hashes.each { |hash| MedTopic.create! hash }
end

Given /^the following Related Medline Topics for "([^"]*)" in (English|Spanish) exist:$/ do |medline_title, language, table|
  locale = language == 'English' ? 'en' : 'es'
  topic = MedTopic.where(:medline_title => medline_title, :locale => locale).first
  table.hashes.each do |hash|
    topic.med_related_topics.create!(:related_medline_tid => hash[:medline_tid],
                                     :title => hash[:medline_title],
                                     :url => hash[:url])
  end
end

Then /^I should see (\d+) search result title links? with url for "([^"]*)"$/ do |count, url|
  page.should have_selector(".title a[href='#{url}']", count: count)
end

Then /^I should see a link to "([^"]*)" with text "([^"]*)"$/ do |url, text|
  page.should have_link(text, :href => url)
end
