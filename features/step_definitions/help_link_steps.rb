Given /^the following HelpLinks exist:$/ do |table|
  table.hashes.each { |hash| HelpLink.create! hash }
end

Then(/^I should be able to access the "(.*?)" help page$/) do |help_page_title|
  click_link('Help Manual')
  find '#help-doc .article'
  page.has_text?(help_page_title)
end
