Feature: Analytics Homepage
  In order to anticipate trends and topics of high public interest
  As an Analyst
  I want to view analytics on usasearch query data. The analytics contains two sections: most popular queries,
    and biggest mover queries. Each of these is broken down into different timeframes (1 day, 7 day, and 30 day).

  Scenario: Viewing the homepage
    Given there is analytics data from "20090831" thru "20090901"
    When I am on the analytics homepage
    Then I should see "Data for September  1, 2009"
    And in "dqs1" I should not see "Query data unavailable"
    And in "dqs7" I should not see "Query data unavailable"
    And in "dqs30" I should not see "Query data unavailable"
    And in "qas1" I should not see "Query data unavailable"
    And in "qas7" I should not see "Query data unavailable"
    And in "qas30" I should not see "Query data unavailable"

  Scenario: No daily query stats available for any time period
    Given there are no daily query stats
    When I am on the analytics homepage
    Then in "dqs1" I should see "Query data unavailable"
    And in "dqs7" I should see "Query data unavailable"
    And in "dqs30" I should see "Query data unavailable"

  Scenario: No query accelerations (biggest movers) available for any time period
    Given there are no query accelerations stats
    When I am on the analytics homepage
    Then in "qas1" I should see "Query data unavailable"
    And in "qas7" I should see "Query data unavailable"
    And in "qas30" I should see "Query data unavailable"

  Scenario: Searching for a query term that starts with a given string
    Given the following DailyQueryStats exist for yesterday:
    | query                       | times |
    | cenobitic                   | 100   |
    | cenolitic                   | 90    |
    | finochio                    | 80    |
    | burmannia                   | 40    |
    And I am on the analytics homepage
    When I fill in "query" with "ceno"
    And I choose "Starts with"
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Results starting with 'ceno'"
    And I should see "cenobitic"
    And I should see "cenolitic"

  Scenario: Searching for a query term that contains a given string
    Given the following DailyQueryStats exist for yesterday:
    | query                       | times |
    | cenobitic                   | 100   |
    | cenolitic                   | 90    |
    | finochio                    | 80    |
    | burmannia                   | 40    |
    And I am on the analytics homepage
    When I fill in "query" with "itic"
    And I choose "Contains"
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Results containing 'itic'"
    And I should see "cenobitic"
    And I should see "cenolitic"

  Scenario: Doing a blank search from the home page
    Given I am on the analytics homepage
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Please enter search term(s)"

  Scenario: Viewing queries that are part of query groups (i.e., semantic sets)
    Given the following DailyQueryStats exist for yesterday:
    | query                       | times   |
    | obama                       | 10000   |
    | health care bill            |  1000   |
    | health care reform          |   100   |
    | obama health care           |    10   |
    | president                   |     1   |
    And the following query groups exist:
    | group      | queries                                                 |
    | POTUS      | obama, president, obama health care                     |
    | hcreform   | health care bill, health care reform, obama health care |
    When I am on the analytics homepage
    Then in "dqs1" I should see "hcreform"
    And in "dqs1" I should see "1110"
    And in "dqs1" I should see "POTUS"
    And in "dqs1" I should see "10011"

  Scenario: Doing a blank search from the home page
    Given I am on the analytics homepage
    And I press "Search"
    Then I should be on the analytics query search results page
    And I should see "Please enter search term(s)"