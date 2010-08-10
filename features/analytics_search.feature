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
    
  Scenario: Bulk adding query terms from analytics search results to an existing query group
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist for yesterday:
    | query                       | times   |
    | obama                       | 10000   |
    | health care bill            |  1000   |
    | health care reform          |   100   |
    | obama health care           |    10   |
    | president                   |     4   |
    | ignore me                   |     1   |
    And the following query groups exist:
    | group      | queries  |
    | hcreform   | medicaid |
    When I am on the analytics homepage
    When I fill in "query" with "health care"
    And I press "Search"
    Then I should be on the analytics query search results page
    When I check "bulk_add_health-care-bill"
    And I check "bulk_add_health-care-reform"
    And I check "bulk_add_obama-health-care"
    And I select "hcreform" from "query_group_name"
    And I press "Add to Query Group"
    Then I should be on the analytics query search results page
    And I should see "The following queries were added to the 'hcreform' query group:"
    And I should see "obama health care, health care reform, health care bill"

  Scenario: Getting empty results from a search on the analytics home page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the analytics homepage
    When I fill in "query" with "abcdef"
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Sorry, no results found for 'abcdef'"
    
  Scenario: Viewing a timeline for a query term from a search result page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist for yesterday:
    | query                       | times   |
    | obama                       | 10000   |
    | health care bill            |  1000   |
    | health care reform          |   100   |
    | obama health care           |    10   |
    | president                   |     4   |
    | ignore me                   |     1   |
    And I am on the analytics homepage
    When I am on the analytics homepage
    When I fill in "query" with "health care"
    And I press "Search"
    Then I should be on the analytics query search results page
    When I follow "health care bill"
    Then I should be on the timeline page for "health care bill"
    And I should see "Interest over time for 'health care bill'"