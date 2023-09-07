Then(/^I should be able to access (\d+) "([^"]*)" rows?$/) do |count, type|
  find "##{type}-#{count.to_i - 1}", visible: true
end
