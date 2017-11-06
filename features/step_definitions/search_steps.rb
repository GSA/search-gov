Then /^I should see (exactly|at least) "([^"]*)" web search results?$/ do |is_exact, count|
  if is_exact == 'exactly'
    selector = '#results .result'
    page.should have_selector selector, count: count
  else
    selector = "#results #result-#{count}"
    page.should have_selector selector
  end
end

Then /^I should see (exactly|at least) "([^"]*)" image search results?$/ do |is_exact, count|
  if is_exact == 'exactly'
    selector = '#results .result.image'
    page.should have_selector selector, count: count
  else
    selector = "#results #result-#{count}.image"
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

Then /^I should see "([^"]*)" after the (\d+)th search result$/ do |value, position|
  page.should have_selector("#results div:nth-of-type(#{position.to_i + 2})", :text => value)
end

Then /^I should not see "([^"]*)" after the (\d+)th search result$/ do |value, position|
  page.should_not have_selector("#results div:nth-of-type(#{position.to_i + 2})", :text => value)
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
  steps %{
    When I fill in "query" with "#{query}"
    And I press "Search" within the search box
  }
end
