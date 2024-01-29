Feature: Search - redesign
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information on the redesigned Search page

  @javascript @a11y
  Scenario: Search with no query on an affiliate page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name | domains        | use_redesigned_results_page |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       | whitehouse.gov | true                        |
    When I am on bar.gov's redesigned search page
    Then I should see "Please enter a search term in the box above."
    And I should not see pagination

  @javascript @a11y 
  Scenario: Searching a domain with Bing results with pagination
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name | domains        | use_redesigned_results_page |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       | whitehouse.gov | true                        |
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

  @javascript @a11y 
  Scenario: Search with I14y results with pagination
    Given the following SearchGov Affiliates exist:
      | display_name   | name           | contact_email      | first_name | last_name | domains            | use_redesigned_results_page |
      | HealthCare.gov | healthcare.gov | aff@healthcare.gov | Jane       | Bar       | www.healthcare.gov | true                        |
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
    And I should see "270 results"
    When I click on the last page ("14")
    Then I should see exactly "20" web search results
    And I should be on page "14" of results
    And I should not see a link to the "Next" page
    And I should see a link to the "Previous" page

  @javascript @a11y
  Scenario: Search with blended results
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | gets_blended_results    | use_redesigned_results_page |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | true                    | true                        |
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
    And I should see "6 results"

  @javascript @a11y 
  Scenario: Search with best bets
    Given the following SearchGov Affiliates exist:
      | display_name   | name           | contact_email      | first_name | last_name | domains            | use_redesigned_results_page |
      | HealthCare.gov | healthcare.gov | aff@healthcare.gov | Jane       | Bar       | www.healthcare.gov | true                        |
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

  @javascript @a11y
  Scenario: News search
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | first_name | last_name | use_redesigned_results_page |
      | bar site         | bar.gov    | aff@bar.gov   | John       | Bar       | true                        |
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
    And I should see "2 results"

  @javascript @a11y 
  Scenario: Docs search
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | usa.gov | true                        |
    When I am on agency.gov's redesigned docs search page
    And I search for "USA" in the redesigned search page
    Then I should see exactly "20" web search results

  @javascript @a11y 
  Scenario: Job search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name |locale | jobs_enabled | use_redesigned_results_page |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en    | 1            | true  |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar       | es    | 1            | true  |

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "jobs"
    And I press "Search"
    Then I should see "Federal Job Openings"
    And I should see "Multiple Locations"
    And I should see "$64,660.00-$170,800.00 PA"
    And I should see an image link to "USAJobs.gov" with url for "https://www.usajobs.gov/"
    And I should see a link to "More federal job openings on USAJobs.gov" with url for "https://www.usajobs.gov/Search/Results?hp=public"

  @javascript @a11y 
  Scenario: News search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | use_redesigned_results_page |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     | true                        |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar       | es     | true                        |

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
    And I press "Search"
    Then the "Enter your search term" field should contain "news item"
    And I should see exactly "20" web search results
    And I should see a link to "2" with class "usa-pagination__button"
    And I should see a link to "Next"
    When I follow "Next"
    And I should see exactly "20" web search results
    And I should see a link to "Previous"
    And I should see a link to "1" with class "usa-pagination__button"
    And I should see "Next"
    When I follow page "5"
    And I follow page "7"
    And I follow page "8"
    And I should see exactly "10" web search results

    When I am on es.agency.gov's "Noticias-1" news search page
    And I should see exactly "5" web search results
  
  @javascript @a11y
  Scenario: Searchers see English Medline Govbox
    Given the following Affiliates exist:
      | display_name | name        | contact_email | first_name | last_name | domains | is_medline_govbox_enabled | use_redesigned_results_page |
      | english site | english-nih | aff@bar.gov   | John       | Bar       | nih.gov | true                      |  true         |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on english-nih's search page
    And I fill in "searchQuery" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search"
    Then I should not see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    And the following Related Medline Topics for "Hippopotomonstrosesquippedaliophobia" in English exist:
      | medline_title | medline_tid | url                                                                          |
      | Hippo1        | 24680       | https://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html |
    When I am on english-nih's search page
    And I fill in "searchQuery" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search"
    Then I should see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears" within the serp med topic govbox
    And I should see a link to "Hippo1" with url for "https://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html"

  @javascript @a11y 
  Scenario: Searchers see Spanish Medline Govbox
    Given the following Affiliates exist:
      | display_name | name        | contact_email | first_name | last_name | domains | is_medline_govbox_enabled | locale |  use_redesigned_results_page |
      | spanish site | spanish-nih | aff@bar.gov   | John       | Bar       | nih.gov | true                      | es     |  true  |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    When I am on spanish-nih's search page
    
    And I fill in "searchQuery" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search"
    Then I should not see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on spanish-nih's search page
    And I fill in "searchQuery" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search"
    Then I should see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales" within the serp med topic govbox

  @javascript @a11y
  Scenario: Searching with custom visual design settings
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_extended_header | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | usa.gov | false               | true                        |
    When I am on agency.gov's redesigned docs search page
    Then I should see the basic header

    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_extended_header | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | usa.gov | true                | true                        |
    When I am on agency.gov's redesigned docs search page
    Then I should see the extended header

  @javascript @a11y 
  Scenario: Searching on sites with federal register documents
    And the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | agency_abbreviation | is_federal_register_document_govbox_enabled | domains  | use_redesigned_results_page | display_created_date_on_search_results |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | DOC                 | true                                        | noaa.gov | true                        | true                                   |
    And the following Federal Register Document entries exist:
      | federal_register_agencies | document_number | document_type | title                                                              | publication_date | comments_close_in_days | start_page | end_page | page_length | html_url                                                                                                                         |
      | DOC,IRS,ITA,NOAA          | 2014-13420      | Notice        | Proposed Information Collection; Comment Request                   | 2014-06-09       | 7                      | 33040      | 33041    | 2           | https://www.federalregister.gov/articles/2014/06/09/2014-13420/proposed-information-collection-comment-request                   |
      | DOC, NOAA                 | 2013-20176      | Rule          | Atlantic Highly Migratory Species; Atlantic Bluefin Tuna Fisheries | 2013-08-19       |                        | 50346      | 50347    | 2           | https://www.federalregister.gov/articles/2013/08/19/2013-20176/atlantic-highly-migratory-species-atlantic-bluefin-tuna-fisheries |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "collection"
    And I press "Search"
    And I should see "A Notice by the Internal Revenue Service, the International Trade Administration and the National Oceanic and Atmospheric Administration posted on June 09, 2014."
    And I should see "Comment period ends in 7 days"
    And I should see "Pages 33040 - 33041 (2 pages) [FR DOC #: 2014-13420]"

  @javascript @a11y
  Scenario: Search without tabs nor related searches
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | domains        | use_redesigned_results_page |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | whitehouse.gov | true                        |
    When I am on bar.gov's redesigned search page
    Then I should see "Everything"
    And I should not see "More"
    And I should not see "Related Searches"

  @javascript @a11y
  Scenario: Search with tabs and one related site on menu
    Given the following Affiliates exist:
      | display_name | name      | contact_email | first_name | last_name | domains        | use_redesigned_results_page |
      | bar site     | bar.gov   | aff@bar.gov   | John       | Bar       | whitehouse.gov | true                        |
      | other site   | other.gov | aff@bad.gov   | John       | Bad       | cdc.gov        | true                        |
    And affiliate "bar.gov" has the following document collections:
      | name   | prefixes               | is_navigable |
      | Topics | http://bar.gov/topics/ | true         |
    And the following Connections exist for the affiliate "bar.gov":
      | connected_affiliate   |   display_name    |
      | other.gov             |   Other Site      |
    When I am on bar.gov's redesigned search page
    Then I should see "Everything"
    And I should see "Topics"
    And I should see "Other Site"

  @javascript @a11y
  Scenario: Search with tabs and more than one related site on menu
    Given the following Affiliates exist:
      | display_name | name      | contact_email | first_name | last_name | domains        | use_redesigned_results_page |
      | bar site     | bar.gov   | aff@bar.gov   | John       | Bar       | whitehouse.gov | true                        |
      | other site   | other.gov | aff@bad.gov   | John       | Bad       | cdc.gov        | true                        |
      | third site   | third.gov | third@bad.gov | Steven     | The Third | third.gov      | true                        |
    And affiliate "bar.gov" has the following document collections:
      | name   | prefixes               | is_navigable |
      | Topics | http://bar.gov/topics/ | true         |
    And the following Connections exist for the affiliate "bar.gov":
      | connected_affiliate   |   display_name    |
      | other.gov             |   Other Site      |
      | third.gov             |   Third Site      |
    When I am on bar.gov's redesigned search page
    Then I should see "Everything"
    And I should see "Topics"
    And I press "View topic"
    And I should see "Other Site"
    And I should see "Third Site"

  @javascript @a11y
  Scenario: Search with too many tabs and multiple related sites
    Given the following Affiliates exist:
      | display_name | name      | contact_email | first_name | last_name | domains        | use_redesigned_results_page |
      | bar site     | bar.gov   | aff@bar.gov   | John       | Bar       | whitehouse.gov | true                        |
      | other site   | other.gov | aff@bad.gov   | John       | Bad       | cdc.gov        | true                        |
      | third site   | third.gov | third@bad.gov | Steven     | The Third | third.gov      | true                        |
    And affiliate "bar.gov" has the following document collections:
      | name                                | prefixes               | is_navigable |
      | Topics                              | http://bar.gov/topics/ | true         |
      | Very very long colllection name one | http://bar.gov/one/    | true         |
      | Very very long colllection name two | http://bar.gov/two/    | true         |
    And the following Connections exist for the affiliate "bar.gov":
      | connected_affiliate   |   display_name    |
      | other.gov             |   Other Site      |
      | third.gov             |   Third Site      |
    When I am on bar.gov's redesigned search page
    Then I should see "Everything"
    And I should see "Topics"
    And I should see "Very very long colllection name one"
    And I should not see "Related Searches"
    And I press "More"
    And I should see "Very very long colllection name two"
    And I should see "View topic"
    And I should see "Other Site"

  @javascript @a11y 
  Scenario: Video news search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | youtube_handles | use_redesigned_results_page     |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     | usgovernment,whitehouse | true |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar       | es     | gobiernousa             | true |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name   | url | is_navigable | is_managed |
      | Videos |     | true         | true       |
    And affiliate "es.agency.gov" has the following RSS feeds:
      | name   | url | is_navigable | is_managed |
      | Videos |     | true         | true       |
    And there are 20 video news items for "usgovernment_channel_id"
    And there are 20 video news items for "whitehouse_channel_id"
    And there are 5 video news items for "gobiernousa_channel_id"

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "video"
    And I press "Search"
    Then I should see exactly "1" redesigned video search result

    When I follow "Videos"
    Then I should see exactly "20" redesigned video search result
    And I should see a link to "2" with class "usa-pagination__button"
    And I should see a link to "Next"

    When I follow "Next"
    Then I should see exactly "20" redesigned video search results
    And I should see a link to "Previous"
    And I should see a link to "1" with class "usa-pagination__button"

    When I follow "Previous"
    And I follow page "2"
    Then I should see exactly "20" redesigned video search results

    When I follow page "1"
    Then I should see exactly "20" redesigned video search results

  @javascript @a11y
  Scenario: Display an Alert on search page
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale |  use_redesigned_results_page |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     |       true                   |
    Given the following Alert exists:
      | affiliate    | text                       | status   | title        |
      | en.agency.gov| New alert for the test aff | Active   |  Test Title  |
    When I am on en.agency.gov's search page
    Then I should see "New alert for the test aff"

  @javascript @a11y
  Scenario: Hide an Alert on search page
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale |  use_redesigned_results_page |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     |       true                   |
    Given the following Alert exists:
      | affiliate    | text                       | status   | title      |
      | en.agency.gov| New alert for the test aff | Inactive | Test Title |
    When I am on en.agency.gov's search page
    Then I should not see "New alert for the test aff"

  @javascript @a11y 
  Scenario: Searching with spelling suggestions
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | Jane       | Bar       | usa.gov | true |
    When I am on agency.gov's search page
    And I search for "qeury" in the redesigned search page
    Then I should see "Showing results for query"
    And I should see "Search instead for qeury"

  @javascript @a11y 
  Scenario: Related searches module
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | use_redesigned_results_page |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar     | en     | true  |
    And the following SAYT Suggestions exist for en.agency.gov:
      | phrase                 |
      | president list         |
      | president inauguration |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "president"
    And I press "Search"
    Then I should see 2 redesigned related searches

  @javascript @a11y
  Scenario: Search for the results with file extension
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | gets_blended_results    | use_redesigned_results_page |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | true                    | true                        |
    And the following IndexedDocuments exist:
      | title                   | description                          | url                               | affiliate | last_crawl_status | published_ago  |
      | The PDF document        | Within the last hour PDF on item     | http://p.whitehouse.gov/hour.pdf  | bar.gov   | OK                | 30 minutes ago |
      | The article with PDF    | Within the last day article on item  | http://p.whitehouse.gov/day.pdf   | bar.gov   | OK                | 8 hours ago    |
    When I am on bar.gov's redesigned search page
    And I search for "PDF" in the redesigned search page
    Then I should see exactly "2" web search results
    And I should see "The PDF document"
    And I should see "p.whitehouse.gov/hour.pdf"
    And I should see "Within the last hour PDF on item"
    And I should not see pagination
    And I should see "2 results"

  @javascript @a11y
  Scenario: Search with site limits
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | use_redesigned_results_page |
      | agency site  | agency.gov | aff@bar.gov   | Jane       | Bar       | usa.gov | true                        |
    When I am on agency.gov's search page with site limited to "www.epa.gov/news"
    And I fill in "Enter your search term" with "carbon emissions"
    And I press "Search"
    Then I should see "We're including results for carbon emissions from www.epa.gov/news only."

  @javascript @a11y
  Scenario: Search with custom no results page
    Given the following Affiliates exist:
      | display_name | name           | contact_email    | first_name   | last_name | domains    | locale | additional_guidance_text     | use_redesigned_results_page |
      | English site | search.gov     | admin@agency.gov | John         | Bar       | search.gov | en     | Sorry, there are no results. | true                        |
    And the "search.gov" affiliate has additional links for the no results module
    When I am on search.gov's search page
    And I fill in "Enter your search term" with "lkssldfkjsldfkjsld kfj"
    And I press "Search"
    Then I should see "Sorry, there are no results."
    And I should see "First no results link"
    And I should see "Second no results link"
