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

Then /^the host url should be (.+)$/ do |host|
  current_host = URI.parse(current_url).host
  if current_host.respond_to? :should
    current_host.should == host
  else
    assert_equal host, current_host
  end
end

Then /^I should see "([^"]*)" link$/ do |title|
  response.body.should have_tag("a img[alt=#{title}]")
end

Then /^I should not see "([^"]*)" link$/ do |title|
  response.body.should_not have_tag("a img[alt=#{title}]")
end

Then /^I should see the following breadcrumbs: (.+)$/ do |breadcrumbs|
  stripped_breadcrumbs = breadcrumbs.gsub(' > ', '')
  Then %{I should see "#{stripped_breadcrumbs}" in the breadcrumbs}
end

Then /^I should see a link to "([^"]*)" with text "([^"]*)"$/ do |href, text|
  response.body.should have_tag("a[href=#{href}]", "#{text}")
end
