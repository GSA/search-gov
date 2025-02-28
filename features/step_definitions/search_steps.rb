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

Then /^I should see "(.+?)" in the video govbox?$/ do |string|
  page.should have_selector('.search-result-video-item', text: string)
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

Given('there are urls indexed for nasa') do
  index = ENV.fetch('SEARCHELASTIC_INDEX')

  ES.client.indices.delete(index:) if ES.client.indices.exists?(index:)
  ES.client.indices.create(index:)

  document = {
    basename: 'nasa-extends-hubble-operations-contract-provides-mission-update',
    changed: '2023-07-26T20:32:39.000+00:00',
    content_en: '3 min read NASA Extends Hubble Operations Contract, Provides Mission Update Jamie Adkins Nov 16, 2021 Article The Hubble Space Telescope, a project of international cooperation between NASA and ESA (European Space Agency), has fundamentally changed the way we view our universe time and again. Now in its 32nd year in space, Hubble has delivered unprecedented insights about the cosmos, from the most distant galaxy observed so far to familiar planets in our neighborhood, including Jupiter, Saturn, Uranus, and Neptune. "Hubble, with its beautiful images and decades-long series of new discoveries about our universe, has captured the imagination of countless individuals and inspired so many," said Dr. Thomas Zurbuchen, associate administrator for NASA\'s Science Mission Directorate at the agency\'s Headquarters in Washington. With Hubble continuing to make groundbreaking discoveries, the agency has awarded a sole source contract extension to the Association of Universities for Research in Astronomy (AURA) in Washington for continued Hubble science operations support at the Space Telescope Science Institute (STScI) in Baltimore, which AURA operates for NASA. The award extends Hubble\'s science mission through June 30, 2026, and increases the value of the existing contract by about $215 million (for a total of about $2.4 billion). This contract extension covers the work necessary for STScI to continue to support the Hubble science program. This support includes the products and services required to execute science system engineering; science ground system development; science operations; management of science research awards and public outreach support; and data archive support for mission data in the Mikulski Archive for Space Telescopes. Currently, the spacecraft team at NASA\'s Goddard Space Flight Center in Greenbelt, Maryland, is investigating an issue involving missed synchronization messages that caused Hubble to suspend science observations Oct. 25. One of the instruments, the Advanced Camera for Surveys, resumed science observations Nov. 7, and continues to function as expected. All other instruments remain in safe mode. During the week of Nov. 8, the Hubble team identified near-term changes that could be made to how the instruments monitor and respond to missed synchronization messages, as well as to how the payload computer monitors the instruments. This would allow science operations to continue even if several missed messages occur. The team has also continued analyzing the instrument flight software to verify that all possible solutions would be safe for the instruments. In the next week, the team will begin to determine the order to recover the remaining instruments. The team expects it will take several weeks to complete the changes for the first instrument. "Mission specialists are working hard to figure out how to bring the other instruments back to full operation," Zurbuchen said. "We expect the spacecraft to have many more years of science ahead, and to work in tandem with the James Webb Space Telescope, launching later this year." Webb, a collaboration between NASA, ESA, and the Canadian Space Agency, will follow up on many of the discoveries that Hubble has made and view them in a different way. While Hubble observes visible wavelengths of light with extensions into ultraviolet and near-infrared, Webb will view the cosmos in the infrared part of the spectrum. Observations from both telescopes will paint a fuller picture of exotic, far away objects, such as feeding black holes, as well as objects in our own solar system. By looking at exoplanets that may harbor habitable environments, for example, the telescopes can get us closer to answering the tantalizing question: Are we alone in the universe? Webb is expected to launch Dec. 18 from French Guiana. For information about Hubble, visit: Hubble',
    # content_type: 'article',
    created: '2021-11-16T15:30:00.000-05:00',
    created_at: '2025-02-19T17:57:30.614Z',
    description_en: 'The Hubble Space Telescope, a project of international cooperation between NASA and ESA (European Space Agency), has fundamentally changed the way we view our',
    domain_name: 'www.nasa.gov',
    extension: '',
    id: '35f9bf2d4dfb0a5c5c3b0aea3badb54d21cf5f54c9cd3dc1b0bafbda0fed6f04',
    language: 'en',
    # mime_type: 'text/html',
    path: 'https://www.nasa.gov/solar-system/nasa-extends-hubble-operations-contract-provides-mission-update/',
    tags: ['goddard space flight center', 'hubble space telescope', 'the solar system', 'goddard space flight center'],
    thumbnail_url: 'https://www.nasa.gov/wp-content/uploads/2020/11/nasa-logo-web-rgb.jpg',
    title_en: 'NASA Extends Hubble Operations Contract, Provides Mission Update - NASA',
    updated_at: '2025-02-19T17:57:30.615Z',
    url_path: '/solar-system/nasa-extends-hubble-operations-contract-provides-mission-update/'
  }

  ES.client.index(index:, body: document)
end
