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
  page.should_not have_selector("input[value='#{value}'][type='submit']")
end

Then /^(?:|I )should see "([^\"]*)" button within "([^\"]*)"$/ do |value, selector|
  page.should have_selector("#{selector} input[value='#{value}'][type='submit']")
end

Then /^(?:|I )should not see "([^\"]*)" button within "([^\"]*)"$/ do |value, selector|
  page.should_not have_selector("#{selector} input[value='#{value}'][type='submit']")
end

Then /^I should see "([^\"]*)" link$/ do |title|
  page.should have_selector("a img[alt='#{title}']")
end

Then /^I should not see "([^\"]*)" link$/ do |title|
  page.should_not have_selector("a img[alt='#{title}']")
end

Then /^I should see "([^"]*)" link within "([^"]*)"$/ do |title, selector|
  page.should have_selector("#{selector} a img[alt='#{title}']")
end

Then /^I should not see "([^"]*)" link within "([^"]*)"$/ do |title, selector|
  page.should_not have_selector("#{selector} a img[alt='#{title}']")
end

Then /^I should see the following breadcrumbs: (.+)$/ do |breadcrumbs|
  stripped_breadcrumbs = breadcrumbs.gsub(' > ', '')
  Then %{I should see "#{stripped_breadcrumbs}" in the breadcrumbs}
end

Then /^I should see a link to "([^"]*)" with url for "([^"]*)"$/ do |name, url|
  page.should have_selector("a[href='#{url}']", :content => name)
end

Then /^I should see a link to "([^\"]*)" with url for "([^\"]*)" within "([^\"]*)"$/ do |name, url, selector|
  page.should have_selector("#{selector} a[href='#{url}']", :content => name)
end

Then /^I should see an image link to "([^"]*)" with url for "([^"]*)"$/ do |name, url|
  page.should have_selector("a[href='#{url}']")
  page.should have_selector("img", :alt => "name")
end

Then /^I should see the browser page titled "([^\"]*)"$/ do |title|
  page.should have_selector("title", :content => title)
end

Then /^I should see "([^\"]*)" in "([^\"]*)" meta tag$/ do |content, name|
  page.should have_selector("meta[name='#{name}'][content='#{content}']")
end

Then /^I should not see "([^\"]*)" meta tag$/ do |name|
  page.should_not have_selector("meta[name='#{name}']")
end