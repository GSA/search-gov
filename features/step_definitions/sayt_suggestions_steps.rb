Then /^I should see a suggestion to search for "(.*)"/ do |query|
  expect(page.find('div.tt-suggestion', visible: :all).text(:all)).to eq query
end
