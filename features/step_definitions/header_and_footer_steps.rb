Then(/^I should be able to access (\d+) (header|footer) link rows?$/) do |count, header_or_footer|
  find "##{header_or_footer}-link-#{count.to_i - 1}", visible: true
end

When(/^I access the dropdown button group/) do
  click_button 'See Other Options'
  find '.btn-group.open', visible: true
end
