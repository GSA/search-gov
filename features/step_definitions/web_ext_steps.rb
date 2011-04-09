When /^I fill in the following within "([^"]*)":$/ do |selector, fields|
  within(selector) do
    fields.rows_hash.each do |name, value|
      When %{I fill in "#{name}" with "#{value}"}
    end
  end
end

Then /^(?:|I )should see "([^"]*)" button$/ do |value|
  response.body.should have_tag("input[value=#{value}][type=submit]")
end

Then /^(?:|I )should not see "([^"]*)" button$/ do |value|
  response.body.should_not have_tag("input[value=#{value}][type=submit]")
end

Then /^(?:|I )should see "([^"]*)" button within "([^"]*)"$/ do |value, selector|
  response.body.should have_tag("#{selector} input[value=#{value}][type=submit]")
end

Then /^(?:|I )should not see "([^"]*)" button within "([^"]*)"$/ do |value, selector|
  response.body.should_not have_tag("#{selector} input[value=#{value}][type=submit]")
end

Then /^I should see "([^"]*)" link$/ do |title|
  response.should have_tag("a img[alt=#{title}]")
end

Then /^I should not see "([^"]*)" link$/ do |title|
  response.should_not have_tag("a img[alt=#{title}]")
end

Then /^I should see "([^"]*)" link within "([^"]*)"$/ do |title, selector|
  response.should have_tag("#{selector} a img[alt=#{title}]")
end

Then /^I should not see "([^"]*)" link within "([^"]*)"$/ do |title, selector|
  response.should_not have_tag("#{selector} a img[alt=#{title}]")
end

Then /^I should see the following breadcrumbs: (.+)$/ do |breadcrumbs|
  stripped_breadcrumbs = breadcrumbs.gsub(' > ', '')
  Then %{I should see "#{stripped_breadcrumbs}" in the breadcrumbs}
end

Then /^I should see a link to "([^"]*)" with url for "([^"]*)"$/ do |name, url|
  response.should have_tag("a[href=#{url}]", "#{name}")
end

Then /^I should see a link to "([^"]*)" with url for "([^"]*)" within "([^"]*)"$/ do |name, url, selector|
  response.should have_tag("#{selector} a[href=#{url}]", "#{name}")
end

Then /^I should see an image link to "([^"]*)" with url for "([^"]*)"$/ do |name, url|
  response.should have_tag("a[href=#{url}] img[alt=#{name}]")
end

Then /^I should see the browser page titled "([^"]*)"$/ do |title|
  within("title") do |content|
    regexp = Regexp.new("^#{title}$")
    content.should contain(regexp)
  end
end

Then /^I should see "([^"]*)" in "([^"]*)" meta tag$/ do |content, name|
  response.should have_tag("meta[name=?][content=?]", name, content)
end

Then /^I should not see "([^"]*)" meta tag$/ do |name|
  response.should_not have_tag("meta[name=?]", name)
end
