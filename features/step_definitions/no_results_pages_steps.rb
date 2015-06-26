Then(/^I should be able to access (\d+) no results pages alternative link rows?$/) do |count|
  find "#no-results-pages-alt-link-#{count.to_i - 1}", visible: true
end
