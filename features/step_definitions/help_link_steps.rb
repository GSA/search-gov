Given /^the following HelpLinks exist:$/ do |table|
  table.hashes.each { |hash| HelpLink.create! hash }
end
