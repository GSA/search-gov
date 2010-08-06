Feature: Analytics Homepage
  In order to anticipate trends and topics of high public interest
  As an Analyst
  I want to view analytics on usasearch query data. The analytics contains two sections: most popular queries,
    and biggest mover queries. Each of these is broken down into different timeframes (1 day, 7 day, and 30 day).

  Scenario: Viewing the homepage
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there is analytics data from "20090831" thru "20090911"
    When I am on the analytics homepage
    Then I should see "Data for September 11, 2009"
    And in "dqs1" I should not see "No queries matched"
    And in "dqs7" I should not see "No queries matched"
    And in "dqs30" I should not see "No queries matched"
    And in "qas1" I should not see "No queries matched"
    And in "qas7" I should not see "No queries matched"
    And in "qas30" I should not see "No queries matched"

  Scenario: No daily query stats available for any time period
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no daily query stats
    When I am on the analytics homepage
    Then in "dqs1" I should see "Not enough historic data"
    And in "dqs7" I should see "Not enough historic data"
    And in "dqs30" I should see "Not enough historic data"

  Scenario: No query accelerations (biggest movers) available for any time period
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no query accelerations stats
    When I am on the analytics homepage
    Then in "qas1" I should see "No queries matched"
    And in "qas7" I should see "No queries matched"
    And in "qas30" I should see "No queries matched"

  Scenario: Viewing queries with at least 4 queries per day that are part of query groups (i.e., semantic sets)
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
    | group      | queries                                                 |
    | POTUS      | obama, president, obama health care, ignore me          |
    | hcreform   | health care bill, health care reform, obama health care |
    When I am on the analytics homepage
    Then in "dqs1" I should see "hcreform"
    And in "dqs1" I should see "1110"
    And in "dqs1" I should see "POTUS"
    And in "dqs1" I should see "10014"

  Scenario: Doing a blank search from the home page
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
        
  Scenario: Visiting the FAQ page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the analytics homepage
    When I follow "FAQ"
    Then I should be on the FAQ page
    And I should see "Frequently Asked Questions about Analytics"
