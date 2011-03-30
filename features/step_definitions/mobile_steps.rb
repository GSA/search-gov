Given /I am using an? (\w+) device/ do |device_name|
  ua_device = device_name == 'mobile' ? 'nokia' : device_name
  page.driver.header 'User-Agent', "#{ua_device}"
end

Then /^"([^\"]*)" should open an email to "([^\"]*)"$/ do |email_link_text, mailto_url|
  page.should have_selector("a[href^='#{mailto_url}']", :content => email_link_text)
end

