Feature: Analytics Homepage
  In order to anticipate trends and topics of high public interest
  As an Analyst
  I want to view analytics on usasearch query data. The analytics contains up to three sections: most popular queries,
    queries getting no results, and biggest mover queries. The most popular queries section is broken down into
    different timeframes (1 day, 7 day, and 30 day).

  Scenario: Viewing the homepage
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there is analytics data from "20090901" thru "20090911"
    When I am on the analytics homepage
    Then I should see "Analytics Center" link in the main navigation bar
    And I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center
    When I follow "Analytics Center" in the main navigation bar
    Then I should be on the analytics homepage
    When I follow "Queries"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center > Queries
    And I should see "Data for September 11, 2009"
    And I should see "Most Popular Queries"
    And in "dqs1" I should see "aaaa"
    And in "dqs7" I should see "aaaa"
    And in "dqs30" I should see "aaaa"
    And I should see "Top Movers"
    And in "qas0" I should see "aaaa"
    And in "qas1" I should see "aaah"
    And in "qas2" I should see "aaao"
    And I should see "No Results Queries"
    And in "nrq0" I should see "gobbledegook aaaa"
    And in "nrq1" I should see "gobbledegook aaah"
    And in "nrq2" I should see "gobbledegook aaao"
    When I follow "aaaa"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center > Query Timeline

  Scenario: No daily query stats available for any time period
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no daily query stats
    When I am on the analytics homepage
    And I follow "Queries"
    Then in "dqs1" I should see "Not enough historic data"
    And in "dqs7" I should see "Not enough historic data"
    And in "dqs30" I should see "Not enough historic data"
    And in "dqgs1" I should see "Not enough historic data"
    And in "dqgs7" I should see "Not enough historic data"
    And in "dqgs30" I should see "Not enough historic data"

  Scenario: No query accelerations (biggest movers) available
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no query accelerations stats
    When I am on the analytics homepage
    And I follow "Queries"
    Then I should not see "Top Movers"

  Scenario: No zero-result queries available
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no zero result query stats
    When I am on the analytics homepage
    And I follow "Queries"
    Then I should not see "No Results Queries"

  Scenario: Viewing queries that are part of query groups (i.e., semantic sets)
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times   |  days_back  |
    | obama                       | 10000   |    1        |
    | health care bill            |  1000   |    1        |
    | health care reform          |   100   |    1        |
    | obama health care           |    10   |    1        |
    | president                   |     4   |    1        |
    | do not ignore me            |     1   |    1        |
    And the following query groups exist:
    | group      | queries                                                 |
    | POTUS      | obama, president, obama health care, do not ignore me   |
    | hcreform   | health care bill, health care reform, obama health care |
    When I am on the analytics homepage
    And I follow "Queries"
    Then in "dqgs1" I should see "hcreform"
    And in "dqgs1" I should see "1110"
    And in "dqgs1" I should see "POTUS"
    And in "dqgs1" I should see "10015"

  Scenario: Viewing Daily Contextual Query Totals when no data exists
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And no DailyContextualQueryTotals exist
    When I am on the analytics homepage
    And I follow "Queries"
    Then I should see "Total USA.gov Most Popular Clickthrus: 0"

  Scenario: Viewing Daily Contextual Query Totals when data exists
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
      | query                                                    | times   |
      | sets most recent date to yesterday                       | 10000   |
    And the DailyContextualQueryTotal for yesterday is "100"
    When I am on the analytics homepage
    And I follow "Queries"
    Then I should see "Total USA.gov Most Popular Clickthrus: 100"
