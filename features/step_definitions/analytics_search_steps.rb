When /^(?:|I )fill in "([^\"]*)" with a date representing "([^\"]*)" days? ago$/ do |field, value|
  fill_in(field, :with => value.to_i.days.ago)
end