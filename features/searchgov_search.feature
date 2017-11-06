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
