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
