# Steps to support mobile device testing

Given /I am using an? (\w+) device/ do |device_name|
  ua_device = device_name == 'mobile' ? 'nokia' : device_name
  header("User-Agent", "WebRat test (#{ua_device})")
end

Then /^"([^\"]*)" should open an email to "([^\"]*)"$/ do |email_link_text, mailto_url|
  response.should have_tag("a[href^=#{mailto_url}]", :text => email_link_text)
end

