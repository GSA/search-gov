Given /I am using an? (\w+) device/ do |device_name|
  header "User-Agent", "WebRat device (#{device_name == 'mobile' ? 'nokia' : device_name})"
end
