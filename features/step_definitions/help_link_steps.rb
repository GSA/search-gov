Given /^the following HelpLinks exist:$/ do |table|
  table.hashes.each { |hash| HelpLink.create! hash }
end

Then(/^I should be able to access the "(.*?)" help page( in the preview layer)?$/) do |help_page_title, preview|
  preview ? find('#preview').click_link('Help?') : click_link('Help?')
  find '#help-doc .article'
  page.should have_selector 'a', text: help_page_title
  click_button '×'
  page.has_no_selector? '#help-doc .article', visible: true
  page.has_no_selector? '.modal-backdrop', visible: true
end
