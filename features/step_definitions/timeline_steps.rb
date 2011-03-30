Then /^the "([^\"]*)" field should be empty$/ do |field|
  if defined?(Spec::Rails::Matchers)
    field_labeled(field).value.should be_nil
  else
    assert field_labeled(field).value.nil?
  end
end

Then /^I should see a query group comparison term form$/ do
  page.should have_selector "form#queries"
  page.should have_selector "input[name='grouped'][value='1']"
end
