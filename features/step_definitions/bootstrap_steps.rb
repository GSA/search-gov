When /^I access the "(.+)" dropdown menu$/ do |dropdown_trigger_name|
  click_link dropdown_trigger_name
  find("##{dropdown_trigger_name.downcase}-menu.dropdown.open")
end
