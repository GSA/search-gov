Then /^the "([^\"]*)" field should be empty$/ do |field|
  if defined?(Spec::Rails::Matchers)
    field_labeled(field).value.should be_nil
  else
    assert field_labeled(field).value.nil?
  end
end

Then /^I should see a query group comparison term form$/ do
  response.should have_tag "form#queries" do
    with_tag "input[name=grouped][value=1]"
  end
end
