Then /^the "([^\"]*)" field should be empty$/ do |field|
  if defined?(Spec::Rails::Matchers)
    field_labeled(field).value.should be_nil
  else
    assert field_labeled(field).value.nil?
  end
end
