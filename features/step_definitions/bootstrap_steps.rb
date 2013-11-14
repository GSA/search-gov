When /^I access the "(.+)" dropdown menu$/ do |dropdown_trigger_name|
  click_link dropdown_trigger_name
  find("##{dropdown_trigger_name.downcase}-menu.dropdown.open")
end

When /^I submit the form by pressing "([^"]*)"$/ do |button_value|
  page.should_not have_xpath("input[type='submit'][disabled='disabled'][value='#{button_value}']")
  click_button button_value
end
