Then(/^I should be able to access (\d+) related site entries$/) do |count|
  find "#connection-#{count.to_i - 1}", visible: true
end
