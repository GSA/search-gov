Given /^the following HelpLinks exist:$/ do |table|
  table.hashes.each { |hash| HelpLink.create! hash }
end

Then(/^I should be able to access the "(.*?)" help page( in the preview layer)?$/) do |help_page_title, preview|
  preview ? find('#preview').click_link('Help?') : click_link('Help?')
  find '#help-doc .article', visible: true
  find 'a', text: help_page_title, visible: true
  find('#help-doc').click_button('×')
  sleep 1
  find('#help-doc[aria-hidden="true"]')
  page.should_not have_selector '.modal-backdrop'
end
