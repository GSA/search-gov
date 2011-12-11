When /^I fill in the following within "([^\"]*)":$/ do |selector, fields|
  within(selector) do
    fields.rows_hash.each do |name, value|
      When %{I fill in "#{name}" with "#{value}"}
    end
  end
end

Then /^(?:|I )should see "([^\"]*)" button$/ do |value|
  page.should have_selector("input[value='#{value}'][type='submit']")
end

Then /^(?:|I )should not see "([^\"]*)" button$/ do |value|
  page.should_not have_button(value)
end

Then /^I should see "([^\"]*)" link$/ do |title|
  page.should have_selector("a img[alt='#{title}']")
end

Then /^I should not see "([^\"]*)" link$/ do |title|
  page.should_not have_selector("a img[alt='#{title}']")
end

Then /^I should see the following breadcrumbs: (.+)$/ do |breadcrumbs|
  stripped_breadcrumbs = breadcrumbs.gsub(' > ', '')
  Then %{I should see "#{stripped_breadcrumbs}" in the breadcrumbs}
end

Then /^I should see a link to "([^"]*)" with url for "([^"]*)"$/ do |name, url|
  page.should have_selector("a[href='#{url}']", :text => name)
end

Then /^I should not see a link to "([^"]*)"$/ do |name|
  page.should_not have_selector("a", :text => name)
end

Then /^I should see an image link to "([^"]*)" with url for "([^"]*)"$/ do |name, url|
  page.should have_selector("a[href='#{url}'] img[alt='#{name}']")
end

Then /^I should see the browser page titled "([^\"]*)"$/ do |title|
  page.should have_selector("title", :text => title)
end

Then /^I should see "([^\"]*)" in "([^\"]*)" meta tag$/ do |content, name|
  page.should have_selector("meta[name='#{name}'][content='#{content}']")
end

Then /^I should not see "([^\"]*)" meta tag$/ do |name|
  page.should_not have_selector("meta[name='#{name}']")
end

Then /^I should see an image with alt text "([^"]*)"$/ do |alt|
  page.should have_selector("img[alt='#{alt}']")
end

Then /^I should not see an image with alt text "([^"]*)"$/ do |alt|
  page.should_not have_selector("img[alt='#{alt}']")
end

Then /^the "([^"]*)" field should contain today's date$/ do |field|
  Then %{the "#{field}" field should contain "#{Date.current.strftime(%Q{%m/%d/%Y})}"}
end

Then /^I should not see a field labeled "([^"]*)"$/ do |label|
  page.should_not have_field(label)
end
