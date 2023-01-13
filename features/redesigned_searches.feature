Feature: Search - redesign
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information on the redesigned Search page

  @javascript
  Scenario: Search with a blank query on an affiliate page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name | domains        |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       | whitehouse.gov |
    When I am on bar.gov's redesigned search page with "" query
    Then I should see "Please enter a search term in the box above."

  @javascript
  Scenario: Searching a domain with Bing results
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name | domains        |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       | whitehouse.gov |
    When I am on bar.gov's redesigned search page with "white house" query
    Then I should see exactly "20" web search results
    And I should see "Remarks by President Biden"

  @javascript
  Scenario: Search with I14y results
    Given the following SearchGov Affiliates exist:
      | display_name   | name           | contact_email      | first_name | last_name | domains            |
      | HealthCare.gov | healthcare.gov | aff@healthcare.gov | Jane       | Bar       | www.healthcare.gov |
    Given there are results for the "searchgov" drawer
    When I am on healthcare.gov's redesigned search page with "marketplace" query
    Then I should see exactly "20" web search results
    And I should see "More info on Health Insurance"

  @javascript
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
    When I am on bar.gov's redesigned search page with "article" query
    Then I should see exactly "6" web search results
    And I should see "The last hour"