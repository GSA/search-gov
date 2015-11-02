Given /^the following Hints exist:$/ do |table|
  table.hashes.each { |hash| Hint.create! hash }
end
