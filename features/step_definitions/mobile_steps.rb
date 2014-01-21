Given /I am using an? (\w+) device/ do |device_name|
  ua_device = device_name == 'mobile' ? 'nokia' : device_name
  page.driver.header 'User-Agent', "#{ua_device}"
end
