# This feature file has been copied and MINIMALLY updated from the original
# legacy_search.feature file.
Feature: Search
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information

  Scenario: Search with a blank query on an affiliate page
    Given the following BingV7 Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name | use_redesigned_results_page |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       | false                       |
    When I am on bar.gov's search page
    And I press "Search" within the search box
    Then I should see "Please enter a search term in the box above."

  Scenario: Search with no results
    Given the following BingV7 Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name | use_redesigned_results_page |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       | false                       |
    When I am on bar.gov's search page
    And I fill in "Enter your search term" with "foobarbazbiz"
    And I press "Search" within the search box
    Then I should see "Sorry, no results found for 'foobarbazbiz'. Try entering fewer or more general search terms."

  Scenario: Searching a domain with Bing results that match a specific news item
    # ACHTUNG! This test will fail unless the news item URL matches a url returned by the web search.
    # So if it breaks, check the urls in the VCR cassette recording from the search:
    # features/vcr_cassettes/Legacy_Search/Searching_a_domain_with_Bing_results_that_match_a_specific_news_item.yml
    Given the following BingV7 Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | domains        | use_redesigned_results_page |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | whitehouse.gov | false                       |
    And affiliate "bar.gov" has the following RSS feeds:
      | name  | url                                  | is_navigable |
      | Press | http://www.whitehouse.gov/feed/press | true         |
    And feed "Press" has the following news items:
      | link                                                                                    | title              | guid  | published_ago | description       |
      | https://www.whitehouse.gov/about-the-white-house/first-families/hillary-rodham-clinton/ | Clinton RSS Test   | uuid1 | day           | clinton news item |
    When I am on bar.gov's search page
    And I search for "Hillary Rodham Clinton first lady"
    Then I should see "Clinton RSS Test"

  Scenario: Visiting English affiliate search with multiple domains
    Given the following BingV7 Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | domains                | use_redesigned_results_page |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | whitehouse.gov,usa.gov | false                       |
    When I am on bar.gov's search page
    And I fill in "Enter your search term" with "president"
    And I press "Search" within the search box
    Then I should see at least "2" web search results

  Scenario: Visiting Spanish affiliate search with multiple domains
    Given the following BingV7 Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | domains                | locale | is_image_search_navigable | use_redesigned_results_page |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | whitehouse.gov,usa.gov | es     | true                      | false                       |
    When I am on bar.gov's search page
    And I fill in "Ingrese su búsqueda" with "president"
    And I press "Buscar" within the search box
    Then I should see at least "2" web search results

  @javascript
  Scenario: Searchers see English Medline Govbox
    Given the following BingV7 Affiliates exist:
      | display_name | name        | contact_email | first_name | last_name | domains | is_medline_govbox_enabled | use_redesigned_results_page |
      | english site | english-nih | aff@bar.gov   | John       | Bar       | nih.gov | true                      | false                       |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search" within the search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    And the following Related Medline Topics for "Hippopotomonstrosesquippedaliophobia" in English exist:
      | medline_title | medline_tid | url                                                                          |
      | Hippo1        | 24680       | https://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search" within the search box
    Then I should see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears" within the med topic govbox
    And I should see a link to "Hippo1" with url for "https://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html"



  @javascript
  Scenario: Searchers see Spanish Medline Govbox
    Given the following BingV7 Affiliates exist:
      | display_name | name        | contact_email | first_name | last_name | domains | is_medline_govbox_enabled | locale | use_redesigned_results_page |
      | spanish site | spanish-nih | aff@bar.gov   | John       | Bar       | nih.gov | true                      | es     | false                       |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar" within the search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar" within the search box
    Then I should see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales" within the med topic govbox



  Scenario: When a searcher clicks on a collection and the query is blank
    Given the following BingV7 Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name  | use_redesigned_results_page |
      | aff site     | aff.gov | aff@bar.gov   | John       | Bar        | false                       |
    And affiliate "aff.gov" has the following document collections:
      | name   | prefixes               | is_navigable |
      | Topics | http://aff.gov/topics/ | true         |
    When I go to aff.gov's search page
    And I follow "Topics" in the search navbar
    Then I should see "Please enter a search term"

  Scenario: Searching indexed document collections
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains        | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | whitehouse.gov | false                       |
    And affiliate "agency.gov" has the following document collections:
      | name      | prefixes                 | is_navigable |
      | Petitions | petitions.whitehouse.gov | true         |
    And the following IndexedDocuments exist:
      | title                   | description                                         | url                                             | affiliate  | last_crawled_at | last_crawl_status |
      | First petition article  | This is an article death star r2d2 xyz3 petition    | http://petitions.whitehouse.gov/petition-1.html | agency.gov | 11/02/2011      | OK                |
      | Second petition article | This is an article on death r2d2 xyz3 star petition | http://petitions.whitehouse.gov/petition-2.html | agency.gov | 11/02/2011      | OK                |
    When I am on agency.gov's search page
    And I follow "Petitions" in the search navbar
    And I search for "death star r2d2 xyz3"
    Then I should see a link to "First petition article" with url for "http://petitions.whitehouse.gov/petition-1.html"
    And I should see a link to "Second petition article" with url for "http://petitions.whitehouse.gov/petition-2.html"

  Scenario: Searching on non navigable document collection
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | usa.gov | false                       |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes                  | is_navigable |
      | Blog | https://www.sba.gov/blogs | false        |
      | Web  | https://www.usa.gov       | true         |
    When I am on agency.gov's "Blog" docs search page
    Then I should see "Blog" in the search navbar
    And I should not see a link to "Web"
    And I should not see a link to "Blog"
    When I search for "sba"
    Then I should see at least "1" web search results
    And I should not see a link to "Blog" in the search navbar

  Scenario: Searching for site specific results using query
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | usa.gov | false                       |
    When I am on agency.gov's search page
    And I search for "jobs site:www.usa.gov"
    Then every result URL should match "usa.gov"
    And I search for "jazz site:wikipedia.org"
    Then every result URL should match "usa.gov"

  Scenario: Affiliate search on affiliate with connections
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | epa.gov | false                       |
      | other site   | other.gov  | aff@bad.gov   | John       | Bad       | cdc.gov | false                       |
    And the following Connections exist for the affiliate "agency.gov":
    | connected_affiliate   |   display_name    |
    | other.gov             |  Other Site       |
    When I am on agency.gov's search page
    And I search for "jobs"
    Then I should see at least "10" web search results
    And every result URL should match "epa.gov"
    And I should see "Other Site"
    When I follow "Other Site" in the search navbar
    Then I should see the browser page titled "jobs - other site Search Results"
    And I should see at least "10" web search results
    And every result URL should match "cdc.gov"

  Scenario: Searching on sites with Featured Collections
    Given the following BingV7 Affiliates exist:
      | display_name   | name          | contact_email   | first_name | last_name | locale | use_redesigned_results_page |
      | agency site    | agency.gov    | john@agency.gov | John       | Bar       | en     | false                       |
    And the following featured collections exist for the affiliate "agency.gov":
      | title           | title_url                         | status   | publish_start_on | publish_end_on |
      | Tornado Warning | http://agency.gov/tornado-warning | active   | 2013-07-01       |                |
    And the following featured collection links exist for featured collection titled "Tornado Warning":
      | title                 | url                                          |
      | Atlantic              | http://www.nhc.noaa.gov/aboutnames.shtml#atl |
      | Eastern North Pacific | http://www.nhc.noaa.gov/aboutnames.shtml#enp |
    When I am on agency.gov's search page
    And I fill in "query" with "warnings for a tornado"
    And I press "Search" within the search box
    Then I should see "Tornado Warning" in the boosted contents section
    And I should see a link to "Atlantic" with url for "http://www.nhc.noaa.gov/aboutnames.shtml#atl"
    And I should see a link to "Eastern North Pacific" with url for "http://www.nhc.noaa.gov/aboutnames.shtml#enp"
    When I fill in "query" with "Atlantic"
    And I press "Search" within the search box
    Then I should see a featured collection link title with "Atlantic" highlighted

  Scenario: Searching on sites with Boosted Contents
    Given the following BingV7 Affiliates exist:
      | display_name   | name          | contact_email   | first_name| last_name | locale | use_redesigned_results_page |
      | agency site    | agency.gov    | john@agency.gov | John      | Bar       | en     | false                       |
      | es agency site | es.agency.gov | john@agency.gov | John      | Bar       | es     | false                       |
    And the following Boosted Content entries exist for the affiliate "agency.gov"
      | url                                        | title                               | description        | status   | publish_start_on | publish_end_on |
      | http://search.gov/releases/2013-05-31.html | Notes for Week Ending May 31, 2013  | multimedia gallery | active   | 2013-08-01       | 2032-01-01     |
      | http://search.gov/releases/2013-06-21.html | Notes for Week Ending June 21, 2013 | spring cleaning    | inactive |                  |                |
    And the following Boosted Content entries exist for the affiliate "es.agency.gov"
      | title                             | url                       | description |
      | la página de prueba de Emergencia | http://www.agency.gov/911 | Some terms  |
    When I am on agency.gov's search page
    And I fill in "query" with "notes"
    And I press "Search" within the search box
    Then I should see a link to "Notes for Week Ending May 31, 2013" with url for "http://search.gov/releases/2013-05-31.html" in the boosted contents section
    And I should not see a link to "Notes for Week Ending June 21, 2013"

    When I am on es.agency.gov's search page
    And I fill in "query" with "emergencia"
    And I press "Buscar" within the search box
    Then I should see a link to "la página de prueba de Emergencia" with url for "http://www.agency.gov/911" in the boosted contents section

  Scenario: Entering a blank advanced search
    Given the following BingV7 Affiliates exist:
      | display_name | name   | contact_email | first_name | last_name | use_redesigned_results_page |
      | USA.gov      | usagov | aff@bar.gov   | John       | Bar       | false                       |
    When I am on usagov's advanced search page
    And I press "Search"
    Then I should be on the search page
    And I should see "Please enter a search term"

  @javascript
  Scenario: Searching with type-ahead suggestions
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | Jane       | Bar       | usa.gov | false                       |
    And the following SAYT Suggestions exist for agency.gov:
      | phrase                |
      | popular search phrase |
    When I am on agency.gov's search page
    And I fill in "query" with "popular"
    Then I should see a suggestion to search for "popular search phrase"

  Scenario: Searching with spelling suggestions
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | Jane       | Bar       | usa.gov | false                       |
    When I am on agency.gov's search page
    And I search for "qeury"
    Then I should see "Showing results for query"
    And I should see "Search instead for qeury"
