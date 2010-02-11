# Steps to support mobile device testing

Given /I am using an? (\w+) device/ do |device_name|
  ua_device = device_name == 'mobile' ? 'nokia' : device_name
  header("User-Agent", "WebRat test device (#{ua_device})")
end
