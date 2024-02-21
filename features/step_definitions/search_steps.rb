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

Then /^I should see exactly "([^"]*)" video govbox search results in the redesigned SERP?$/ do |count|
  selector = '.search-result-video-item'
  page.should have_selector selector, count: count
end

Then /^I should see (Powered by|Generado por) Bing logo$/ do |text|
  page.should have_selector '.content-provider .bing', text: text
end

Then /^I should see (Powered by|Generado por) (Bing|Search.gov)$/ do |text, engine|
  page.should have_selector('.powered-by', text: text)
  visibility = engine == 'Bing' ? 'hidden' : ''
  page.should have_selector('.engine', text: engine, visible: visibility.to_sym)
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

Then /I (should|should not) see pagination/ do |should|
  if should == 'should'
    page.should have_selector('.usa-pagination')
  else
    page.should_not have_selector('.usa-pagination')
  end
end

Then /I (should|should not) see a link to the "(.+?)" page/ do |should, page_link|
  if should == 'should'
    page.should have_link(page_link)
  else
    page.should_not have_link(page_link)
  end
end

When /I click on the "(.+?)" page/ do |link|
  click_link(link)
end

Then /I should be on page "(.+?)" of results/ do |page|
  current_page = find('a[class="usa-link usa-pagination__button usa-current"]').text
  expect(current_page).to eq(page)
end

Then /I should see a link to the last page \("(.+?)"\)/ do |last_page|
  page.should have_link(last_page)
end

When /I click on the last page \("(.+?)"\)/ do |last_page|
  click_link(last_page)
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
