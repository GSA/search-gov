Feature: Groups and Trends
  In order to anticipate trends and semantic topics of high public interest
  As an Analyst
  I want to view analytics on most popular query groups and biggest mover queries. The most popular query groups
  section is broken down into different timeframes (1 day, 7 day, and 30 day). The biggest mover section is for a single day.

  Scenario: Viewing the main groups and trends page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist for affiliate "usasearch.gov":
      | query                       | times |  day        |
      | abcdef 10                   | 100   |  2011-09-11 |
    And the following DailyPopularQueryGroups exist for "2011-09-11":
      | query_group    | times  | time_frame |
      | Hcreform1      | 1110   | 1          |
      | POTUS1         | 10015  | 1          |
      | Hcreform7      | 7110   | 7          |
      | POTUS7         | 70015  | 7          |
      | Hcreform30     | 30110  | 30         |
      | POTUS30        | 300015 | 30         |
    And the following MovingQueries exist for "2011-09-11":
      | query          | times  |
      | abcdef 10      | 1110   |
      | abcdef 12      | 1113   |
      | abcdef 13      | 1115   |
    When I am on the analytics homepage
    And I follow "Groups & Trends"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center > Groups & Trends
    And I should see "Data for September 11, 2011"
    And in "dqgs1" I should see "Hcreform1"
    And in "dqgs1" I should see "1110"
    And in "dqgs1" I should see "POTUS1"
    And in "dqgs1" I should see "10015"
    And in "dqgs7" I should see "Hcreform7"
    And in "dqgs7" I should see "7110"
    And in "dqgs7" I should see "POTUS7"
    And in "dqgs7" I should see "70015"
    And in "dqgs30" I should see "Hcreform30"
    And in "dqgs30" I should see "30110"
    And in "dqgs30" I should see "POTUS30"
    And in "dqgs30" I should see "300015"
    And I should see "Top Movers"
    And in "qas0" I should see "abcdef 13"
    And in "qas1" I should see "abcdef 12"
    And in "qas2" I should see "abcdef 10"

  Scenario: No query accelerations (biggest movers) available
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no query accelerations stats
    When I am on the analytics homepage
    And I follow "Groups & Trends"
    Then I should not see "Top Movers"
