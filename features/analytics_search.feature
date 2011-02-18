Feature: Analytics Search
  In order to anticipate trends and topics of high public interest
  As an Analyst and an Affiliate
  I want to do fulltext search on query data over a given date range.

  Scenario: Doing a fulltext search for a query term to see query counts for usasearch.gov in English locale for a given date range
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times | affiliate     | locale |   days_back   |
    | pollution                    | 100   | usasearch.gov | en     |      1        |
    | old pollution                | 10    | usasearch.gov | en     |      30       |
    | pollutant                  | 90    | usasearch.gov | en     |      1        |
    | el pollution                 | 88    | usasearch.gov | es     |      1        |
    | social pollution             | 70    | noaa.gov      | en     |      1        |
    | finochio                    | 80    | usasearch.gov | en     |      1        |
    And I am on the analytics homepage
    When I fill in "query" with "pollution"
    And I fill in "analytics_search_start_date" with a date representing "29" days ago
    And I fill in "analytics_search_end_date" with a date representing "1" day ago
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "USASearch > Search.USA.gov > Analytics Center > Query Search"
    And I should see "Matches for 'pollution'"
    And I should see "pollution"
    And I should see "pollutant"
    And I should not see "social pollution"
    And I should not see "old pollution"
    And I should not see "finochio"
    And I should not see "Add to Query Group"

  Scenario: Doing a fulltext search for a query term to see query counts for one of my affiliates in English locale
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist:
    | query                       | times | affiliate     | locale |  days_back   |
    | pollution                    | 100   | usasearch.gov | en     |      1       |
    | old pollution                | 10    | usasearch.gov | en     |      30      |
    | pollutant                  | 90    | usasearch.gov | en     |      1       |
    | el pollution                 | 88    | usasearch.gov | es     |      1       |
    | social pollution             | 70    | aff.gov       | en     |      1       |
    | finochio                    | 80    | usasearch.gov | en     |      1       |
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query Logs"
    And I fill in "query" with "pollution"
    And I fill in "analytics_search_start_date" with a date representing "29" days ago
    And I fill in "analytics_search_end_date" with a date representing "1" day ago
    And I press "Search"
    Then I should see "Matches for 'pollution'"
    And I should see "social pollution"
    And I should not see "old pollution"
    And I should not see "pollutant"
    And I should not see "Add to Query Group"

  Scenario: Doing a blank search from the analytics home page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the analytics homepage
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Please enter search term(s)"

  Scenario: Bulk adding query terms from analytics search results to an existing query group
    Given I am logged in with email "marilyn@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times   |  days_back  |
    | obama                       | 10000   |     2       |
    | health care bill            |  1000   |     2       |
    | health care reform          |   100   |     2       |
    | obama health care           |    10   |     2       |
    | president                   |     4   |     2       |
    | ignore me                   |     1   |     2       |
    And the following query groups exist:
    | group     | queries            |
    | hcreform  | medicaid           |
    | hcreform  | obama health care  |
    | no_dups   | blargh             |
    When I am on the analytics homepage
    When I fill in "query" with "health care"
    And I fill in "analytics_search_start_date" with a date representing "29" days ago
    And I fill in "analytics_search_end_date" with a date representing "1" day ago
    And I press "Search"
    Then I should be on the analytics query search results page
    When I check "bulk_add_health-care-bill"
    And I check "bulk_add_health-care-reform"
    And I check "bulk_add_obama-health-care"
    And I select "hcreform" from "query_group_name"
    And I press "Add to Query Group"
    Then I should be on the analytics homepage
    And I should see "2 queries added to group 'hcreform'; 1 duplicates ignored."

    When I fill in "query" with "health care"
    And I press "Search"
    Then I should be on the analytics query search results page
    When I check "bulk_add_health-care-bill"
    And I check "bulk_add_obama-health-care"
    And I select "no_dups" from "query_group_name"
    And I press "Add to Query Group"
    Then I should be on the analytics homepage
    And I should see "2 queries added to group 'no_dups'"

  Scenario: Getting empty results from a search on the analytics home page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the analytics homepage
    When I fill in "query" with "abcdef"
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Sorry, no results found for 'abcdef'"

  Scenario: Viewing a timeline for a query term from a search result page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times   |   days_back    |
    | obama                       | 10000   |       1        |
    | health care bill            |  1000   |       1        |
    | health care reform          |   100   |       1        |
    | obama health care           |    10   |       1        |
    | president                   |     4   |       1        |
    | ignore me                   |     1   |       1        |
    And I am on the analytics homepage
    When I fill in "query" with "health care"
    And I fill in "analytics_search_start_date" with a date representing "29" days ago
    And I fill in "analytics_search_end_date" with a date representing "1" day ago
    And I press "Search"
    Then I should be on the analytics query search results page
    When I follow "health care bill"
    Then I should be on the timeline page for "health care bill"
    And I should see "Interest over time for 'health care bill'"
