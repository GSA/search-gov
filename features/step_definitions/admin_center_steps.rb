Then /^I should see (.*) selected in the site selector$/ do |site_display_name|
  page.should have_xpath("//select[@id='site_select']/option[@selected][text()='#{site_display_name}']")
end
