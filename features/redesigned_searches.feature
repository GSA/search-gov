Feature: Search - redesign
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information on the redesigned Search page

  @javascript @a11y @a11y_wip
  Scenario: Search with no query on an affiliate page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name | domains        |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       | whitehouse.gov |
    When I am on bar.gov's redesigned search page
    Then I should see "Please enter a search term in the box above."
    And I should not see pagination

  @javascript @a11y @a11y_wip
  Scenario: Searching a domain with Bing results with pagination
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name | domains        |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       | whitehouse.gov |
    When I am on bar.gov's redesigned search page
    And I search for "white house" in the redesigned search page
    Then I should see exactly "20" web search results
    And I should see "The White House"
    And I should see "www.whitehouse.gov/"
    And I should see "President Biden's Budget Topics: Reproductive Rights"
    And I should be on page "1" of results
    And I should see pagination
    And I should see a link to the "Next" page
    And I should not see a link to the "Previous" page
    When I click on the "Next" page
    Then I should see exactly "20" web search results
    And I should be on page "2" of results
    And I should see a link to the "Next" page
    And I should see a link to the "Previous" page
    When I search for "America" in the redesigned search page
    Then I should be on page "1" of results
    And I should see exactly "20" web search results
    And I should see a link to the "Next" page
    And I should not see a link to the "Previous" page

  @javascript @a11y @a11y_wip
  Scenario: Search with I14y results with pagination
    Given the following SearchGov Affiliates exist:
      | display_name   | name           | contact_email      | first_name | last_name | domains            |
      | HealthCare.gov | healthcare.gov | aff@healthcare.gov | Jane       | Bar       | www.healthcare.gov |
    Given there are results for the "searchgov" drawer
    When I am on healthcare.gov's redesigned search page
    And I search for "marketplace" in the redesigned search page
    Then I should see exactly "20" web search results
    And I should see "Marketplace"
    And I should see "www.healthcare.gov/glossary/marketplace"
    And I should see "More info on Health Insurance"
    And I should see pagination
    And I should be on page "1" of results
    And I should see a link to the "Next" page
    And I should not see a link to the "Previous" page
    And I should see a link to the last page ("14")
    When I click on the last page ("14")
    Then I should see exactly "20" web search results
    And I should be on page "14" of results
    And I should not see a link to the "Next" page
    And I should see a link to the "Previous" page

  @javascript @a11y @a11y_wip
  Scenario: Search with blended results
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | gets_blended_results    |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | true                    |
    And the following IndexedDocuments exist:
      | title                   | description                          | url                                 | affiliate | last_crawl_status | published_ago  |
      | The last hour article   | Within the last hour article on item | http://p.whitehouse.gov/hour.html   | bar.gov   | OK                | 30 minutes ago |
      | The last day article    | Within the last day article on item  | http://p.whitehouse.gov/day.html    | bar.gov   | OK                | 8 hours ago    |
      | The last week article   | Within last week article on item     | http://p.whitehouse.gov/week.html   | bar.gov   | OK                | 3 days ago     |
      | The last month article  | Within last month article on item    | http://p.whitehouse.gov/month.html  | bar.gov   | OK                | 15 days ago    |
      | The last year article   | Within last year article on item     | http://p.whitehouse.gov/year.html   | bar.gov   | OK                | 60 days ago    |
      | The last decade article | Within last decade article on item   | http://p.whitehouse.gov/decade.html | bar.gov   | OK                | 5 years ago    |
    When I am on bar.gov's redesigned search page
    And I search for "article" in the redesigned search page
    Then I should see exactly "6" web search results
    And I should see "The last hour article"
    And I should see "p.whitehouse.gov/hour.html"
    And I should see "Within the last hour article on item"
    And I should not see pagination

  @javascript @a11y @a11y_wip
  Scenario: Search with best bets
    Given the following SearchGov Affiliates exist:
      | display_name   | name           | contact_email      | first_name | last_name | domains            |
      | HealthCare.gov | healthcare.gov | aff@healthcare.gov | Jane       | Bar       | www.healthcare.gov |
    Given the following Boosted Content entries exist for the affiliate "healthcare.gov"
      | url                                          | title             | description                                            |
      | http://healthcare.gov/hippopotamus-amphibius | Hippopotamus item | large, mostly herbivorous mammal in sub-Saharan Africa |
    And the following featured collections exist for the affiliate "healthcare.gov":
      | title                  | status | publish_start_on |
      | Hippopotamus graphic   | active | 2013-07-01       |
    Given there are results for the "searchgov" drawer
    When I am on healthcare.gov's redesigned search page
    And I search for "hippopotamus" in the redesigned search page
    Then I should see 1 Best Bets Text
    And I should see 1 Best Bets Graphic
    And I should see "Recommended by HealthCare.gov"
    And I should see "Hippopotamus item"
    And I should see "http://healthcare.gov/hippopotamus-amphibius"
    And I should see "large, mostly herbivorous mammal in sub-Saharan Africa"
    And I should see "Hippopotamus graphic"

  @javascript @a11y @a11y_wip
  Scenario: News search
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | first_name | last_name |
      | bar site         | bar.gov    | aff@bar.gov   | John       | Bar       |
    And affiliate "bar.gov" has the following RSS feeds:
      | name   | url                                  | is_navigable |
      | Press  | http://www.whitehouse.gov/feed/press | true         |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | item First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | item Next news item for the feed  |
    When I am on bar.gov's redesigned news search page
    And I search for "item" in the redesigned search page
    Then I should see "First"
    And I should see "Second"
    And I should see exactly "2" web search results

  @javascript @a11y @a11y_wip
  Scenario: Docs search
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | usa.gov |
    When I am on agency.gov's redesigned docs search page
    And I search for "USA" in the redesigned search page
    Then I should see exactly "20" web search results

  @javascript @a11y @a11y_wip
  Scenario: Job search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name |locale | jobs_enabled |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en    | 1            |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar       | es    | 1            |

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "jobs"
    And I press "Search"
    Then I should see "Federal Job Openings"
    And I should see "Washington, District of Columbia"
    And I should see "$64,660.00-$170,800.00 PA"
    And I should see an image link to "USAJobs.gov" with url for "https://www.usajobs.gov/"
    And I should see a link to "More federal job openings on USAJobs.gov" with url for "https://www.usajobs.gov/Search/Results?hp=public"

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "blablah jobs"
    And I press "Search"
    Then I should see an image link to "USAJobs.gov" with url for "https://www.usajobs.gov/"
    And I should see "No job openings in your region match your search"
    And I should see a link to "More federal job openings on USAJobs.gov" with url for "https://www.usajobs.gov/Search/Results?hp=public"

    When I am on es.agency.gov's search page
    And I fill in "Ingrese su búsqueda" with "blablah trabajo"
    And I press "Buscar"
    Then I should see an image link to "USAJobs.gov" with url for "https://www.usajobs.gov/"
    And I should see "Ninguna oferta de trabajo en su región coincide con su búsqueda"
    And I should see a link to "Más trabajos en el gobierno federal en USAJobs.gov" with url for "https://www.usajobs.gov/Search/Results?hp=public"

  @javascript @a11y @a11y_wip
  Scenario: News search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar       | es     |

    And affiliate "en.agency.gov" has the following RSS feeds:
      | name   | url                              |
      | News-1 | http://en.agency.gov/feed/news-1 |
    And affiliate "es.agency.gov" has the following RSS feeds:
      | name       | url                                  |
      | Noticias-1 | http://es.agency.gov/feed/noticias-1 |

    And there are 150 news items for "News-1"
    And there are 5 news items for "Noticias-1"

    When I am on en.agency.gov's "News-1" news search page
    And I fill in "Enter your search term" with "news item"
    And I press "Search" within the search box

    Then the "Enter your search term" field should contain "news item"
    And I should see "Any time" within the current time filter
    And I should see "Most recent" within the current sort by filter
    And I should see "150 results"
    And I should see "Powered by Search.gov"
    And I should see exactly "20" web search results
    
    And I should see a link to "2" with class "pagination-numbered-link"
    And I should see a link to "Next"
    When I follow "Next"
    Then I should see "150 results"
    And I should see exactly "20" web search results
    And I should see a link to "Previous"
    And I should see a link to "1" with class "pagination-numbered-link"
    And I should see "Next"
    When I follow "5"
    And I follow "7"
    And I follow "8"
    Then I should see "150 results"
    And I should see exactly "10" web search results

    When I am on es.agency.gov's "Noticias-1" news search page
    Then I should see "Generado por Search.gov"
    And I should see at least "5" web search results
