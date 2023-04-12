Then /^I should see (exactly|at least) "([^"]*)" web search results?$/ do |is_exact, count|
  if is_exact == 'exactly'
    selector = '#results .result'
    page.should have_selector selector, count: count
  else
    selector = "#results #result-#{count}"
    page.should have_selector selector
  end
end

Then /^I should see (exactly|at least) "([^"]*)" video( govbox)? search results?$/ do |is_exact, count, is_govbox|
  if is_exact == 'exactly'
    selector = is_govbox.present? ? '#video-news-items .result.video' : '#results .result.video'
    page.should have_selector selector, count: count
  else
    selector = is_govbox.present? ? "#video-news-items #video-news-item-#{count}" : "#results #result-#{count}.video"
    page.should have_selector selector
  end
end

Then(/^I should see (Powered by|Generado por) (Azure|Bing) logo$/) do |text, engine|
  page.should have_selector ".content-provider .#{engine.downcase}", text: text
end

Then /^I should see a (left|right) aligned SERP logo$/ do |alignment|
  page.should have_selector ".header-logo.logo-#{alignment} img"
end

Then /^I should see a left aligned menu button$/ do
  page.should have_selector '.menu-button-left'
end

When /^I search for "(.+?)"$/ do |query|
  steps %(
    When I fill in "query" with "#{query}"
    And I press "Search" within the search box
  )
end

When /^I search for "(.+?)" in the redesigned search page$/ do |query|
  steps %( When I fill in "searchQuery" with "#{query}" )
  find('button[data-testid="search-submit-btn"]').click
end

Then /every result URL should match "(.+?)"$/ do |str|
  results = page.find_all('.content-block-item.result')
  results.each { |result| result.should have_link(href: %r{#{str}}i) }
end

# Hitting the production I14y API during tests is unsafe, and we currently
# lack a straightforward way to set up a dev i14y sandbox. So for very basic
# integration search tests, we're stubbing a simple response. This does NOT
# test various search params and varying responses; it simply ensures
# that nothing blows up during searches, and allows us to verify that certain elements
# appear on the i14y SERP.
When /there are results for the "([^"]*)" drawer$/ do |drawer|
  response = Rails.root.join('spec/fixtures/json/i14y/marketplace.json').read
  stub_request(:get, %r{#{I14y.host}/api/v1/collections/search\?handles=#{drawer}}).
    to_return(status: 200, body: response)
end
