Feature: SearchGov search
  In order to get government-related search results
  As a site visitor to a site using the Search.gov search engine
  I want to be able to search for multiple types of data

  Background:
    Given the following SearchGov Affiliates exist:
      | display_name | name | contact_email | contact_name | header         | domains                     |
      | EPA          | epa  | aff@epa.gov   | Jane Bar     | EPA.gov Header | www.epa.gov,archive.epa.gov |

  Scenario: Everything search
    When I am on epa's search page
    Then I should see "Please enter a search term in the box above."
    And I should not see "Refine your search"

  Scenario: Image search
    When I am on epa's image search page
    When I fill in "query" with "global warming"
    And I press "Search"
    Then I should see the browser page titled "global warming - EPA Search Results"
    And I should see 20 image results
    And I should see "Powered by Bing"

  Scenario: Collection search
    Given affiliate "epa" has the following document collections:
      | name | prefixes             |
      | News | www.epa.gov/one      |
    When I am on epa's "News" docs search page
    Then I should see "Please enter a search term in the box above."

  Scenario: News search
    Given affiliate "epa" has the following RSS feeds:
      | name  | url                         | is_navigable | shown_in_govbox |
      | Press | http://www.epa.gov/newsroom | true         | true            |
    And feed "Press" has the following news items:
      | link                           | title         | description  |
      | https://www.epa.gov/news1.html | exciting news | this is news |
    And the rss govbox is enabled for the site "epa"
    When I am on epa's search page
    And I search for "exciting"
    Then I should see "exciting news"
    When I am on epa's "Press" mobile news search page
    Then I should see "Refine your search"

  Scenario: Display an Alert on search page
    Given the following Alert exists:
      | affiliate | text                       | status | title      |
      | epa       | New alert for the test aff | Active | Test Title |
    When I am on epa's search page
    Then I should see "New alert for the test aff"
    Given the following Alert exists:
      | affiliate | text                       | status   | title      |
      | epa       | New alert for the test aff | Inactive | Test Title |
    When I am on epa's search page
    Then I should not see "New alert for the test aff"
