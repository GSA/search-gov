When /^I fill in the following within "([^"]*)":$/ do |selector, fields|
  within(selector) do
    fields.rows_hash.each do |name, value|
      When %{I fill in "#{name}" with "#{value}"}
    end
  end
end

Then /^I should see the following breadcrumbs: (.+)$/ do |breadcrumbs|
  stripped_breadcrumbs = breadcrumbs.gsub(' > ', '')
  step %{I should see "#{stripped_breadcrumbs}" in the breadcrumbs}
end

Then /^I should see a link to "([^"]*)" with url (for|that starts with|that ends with) "([^"]*)"$/ do |name, attribute_selector, url|
  link_matcher =
    case attribute_selector
    when 'that starts with' then /^#{Regexp.escape(url)}/
    when 'that ends with' then /#{Regexp.escape(url)}$/
    else url
    end

  page.should have_link(name, href: link_matcher)
end

Then /^I should see a link to "([^"]*)"$/ do |name|
  page.should have_link(name)
end

Then /^I should not see a link to "([^"]*)"$/ do |name|
  page.should_not have_selector("a", :text => name)
end

Then /^I should see a link to "([^"]*)" with class "([^"]*)"$/ do |name, klass|
  page.should have_selector("a.#{klass}", :text => name)
end

Then /^I should not see a link to "([^"]*)" with class "([^"]*)"$/ do |name, klass|
  page.should_not have_selector("a.#{klass}", :text => name)
end

Then /^I should see an image link to "([^"]*)" with url for "([^"]*)"$/ do |name, url|
  page.should have_selector("a[href='#{url}'] img[alt='#{name}']")
end

Then /^I should not see an image link to "([^"]*)" with url for "([^"]*)"$/ do |name, url|
  page.should_not have_selector("a[href='#{url}'] img[alt='#{name}']")
end

Then /^I should see the browser page titled "([^"]*)"$/ do |title|
  page.should have_title title
end

Then /^I should see an image with alt text "([^"]*)"$/ do |alt|
  page.should have_selector("img[alt='#{alt}']")
end

Then /^I should not see an image with alt text "([^"]*)"$/ do |alt|
  page.should_not have_selector("img[alt='#{alt}']")
end

Then /^I should see an image with src "([^"]*)"$/ do |src|
  page.should have_selector("img[src='#{src}']")
end

Then /^I should not see a field labeled "([^"]*)"$/ do |label|
  page.should_not have_field(label)
end

And /^the "([^"]*)" field should be blank$/ do |field|
  field = find_field(field)
  field_value = (field.tag_name == 'textarea') ? field.text : field.value
  field_value.should be_blank
end

Then /^the "([^"]*)" radio button should be checked$/ do |label|
  find_field(label)['checked'].should(be_truthy)
end

Then /^the "([^"]*)" radio button should not be checked$/ do |label|
  find_field(label)['checked'].should(be_falsey)
end

Then /^the page body should (contain|match) "([^"]*)"$/ do |matcher, content|
  page.body.should include(content) if matcher == 'contain'
  page.body.should match(/#{content}/) if matcher == 'match'
end

Then /^the page body should not contain "([^"]*)"$/ do |content|
  page.body.should_not include("#{content}")
end

Then /^I should see an s3 image "(.*?)"$/ do |image_file_name|
  image_url = page.find(:xpath, '//img')[:src]
  image_url.should =~ /s3\.amazonaws\.com.+#{Regexp.escape(image_file_name)}/
  lambda { URI.parse(image_url).open }.should_not raise_error
end

Then /^I should find "(.+)" in (.+)$/ do |text, locator|
  find selector_for(locator), text: text, visible: true
end

Then(/^the "(.*?)" select field should contain (\d+) options?$/) do |label, count|
  field = find_field(label)
  field.find(:xpath, './/option', count: count)
end

Then /^I should see the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    step %{the "#{name}" field should contain "#{value}"}
  end
end

And /^the "([^"]*)" input should( not)? be required$/ do |id, negate|
  sel = "input##{id}"
  page.should have_selector(sel)
  page.find(sel)[:required].should eq(negate ? nil : 'required')
end
