Then /^the "([^\"]*)" field should be empty$/ do |field|
  find_field(field).value.should be_blank
end
