Feature: Analytics Search
  In order to anticipate trends and topics of high public interest
  As an Analyst and an Affiliate
  I want to do fulltext search on query data.

  Scenario: Doing a fulltext search for a query term to see query counts for usasearch.gov in English locale
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist for yesterday:
    | query                       | times | affiliate     | locale |
    | security                    | 100   | usasearch.gov | en     |
    | securities                  | 90    | usasearch.gov | en     |
    | el security                 | 88    | usasearch.gov | es     |
    | social security             | 70    | noaa.gov      | en     |
    | finochio                    | 80    | usasearch.gov | en     |
    And I am on the analytics homepage
    When I fill in "query" with "security"
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Matches for 'security'"
    And I should see "security"
    And I should see "securities"
    And I should not see "social security"
    And I should not see "finochio"

  Scenario: Doing a fulltext search for a query term to see query counts for one of my affiliates in English locale
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist for yesterday:
    | query                       | times | affiliate     | locale |
    | security                    | 100   | usasearch.gov | en     |
    | securities                  | 90    | usasearch.gov | en     |
    | el security                 | 88    | usasearch.gov | es     |
    | social security             | 70    | aff.gov       | en     |
    | finochio                    | 80    | usasearch.gov | en     |
    When I go to the user account page
    And I follow "Analytics"
    And I fill in "query" with "security"
    And I press "Search"
    Then I should see "Matches for 'security'"
    And I should see "social security"
    And I should not see "securities"

  Scenario: Doing a blank search from the analytics home page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the analytics homepage
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Please enter search term(s)"

  Scenario: Getting empty results from a search on the analytics home page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the analytics homepage
    When I fill in "query" with "abcdef"
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Sorry, no results found for 'abcdef'"
