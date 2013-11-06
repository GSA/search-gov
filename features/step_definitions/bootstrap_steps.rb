When /^I access the "(.+)" dropdown menu$/ do |dropdown_trigger_name|
  click_link dropdown_trigger_name
  find("##{dropdown_trigger_name.downcase}-menu.dropdown.open")
end

When /^I dismiss the "(.+)" modal dialog$/ do |selector_id|
  page.find("##{selector_id}").click_button '×'
  page.find "##{selector_id}[aria-hidden='true']", visible: false
  page.should_not have_selector '.modal-backdrop'
end
