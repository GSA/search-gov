Feature: Monthly Reports
  In order to generate monthly reports on monthly site and search activity
  As an Analyst
  I want to view the total number of queries,
    the total number of unique site visitors,
    the total number of page views and total number of click throughs,
    the most popular queries for English locale and default affiliate,
    and the most popular query groups for English locale and default affiliate.

  Scenario: Viewing module click stats on the the Reports homepage
    Given the following MonthlyClickTotals exist
    | year  | month | source  | total    |
    | 2010  | 2     | FORM    | 4000     |
    | 2010  | 2     | FAQS    | 300      |
    | 2010  | 3     | BWEB    | 200      |
    | 2010  | 3     | BREL    | 10       |
    And I am logged in with email "analyst@fixtures.org" and password "admin"
    When I am on the analytics homepage
    And I follow "Monthly Reports"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center > Monthly Reports
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then in "module_click_stats" I should see "FORM"
    And in "module_click_stats" I should see "4,000"
    And in "module_click_stats" I should see "FAQS"
    And in "module_click_stats" I should see "300"
    When I select "March 2010" as the report date
    And I press "Get Usage Stats"
    Then in "module_click_stats" I should see "BWEB"
    And in "module_click_stats" I should see "200"
    And in "module_click_stats" I should see "BREL"
    And in "module_click_stats" I should see "10"

  Scenario: Viewing most popular queries across all affiliates and locales
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following MonthlyPopularQueries exist
    | year  | month | query | times | is_grouped |
    | 2010  | 2     | term1 | 400   | false      |
    | 2010  | 3     | term1 | 300   | false      |
    When I am on the reports homepage
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then I should see "Most Popular Queries"
    And in "pop_queries" I should see "term1"
    And in "pop_queries" I should see "400"
    And I should not see "term2"

  Scenario: Viewing queries that are part of query groups (i.e., semantic sets)
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following MonthlyPopularQueries exist
    | year  | month   | query     | times | is_grouped  |
    | 2010  | 2       | POTUS     | 10015 | true        |
    | 2010  | 2       | hcreform  | 1110  | true        |
    | 2010  | 2       | obama     | 100   | false       |
    When I am on the reports homepage
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then in "pop_query_groups" I should see "hcreform"
    And in "pop_query_groups" I should see "1110"
    And in "pop_query_groups" I should see "POTUS"
    And in "pop_query_groups" I should see "10015"

  Scenario: Viewing DailyUsageStats on the the Reports homepage
    Given the following DailyUsageStats exists for each day in yesterday's month
    | profile     | total_queries | total_page_views  | total_unique_visitors | total_clicks  | affiliate     |
    | English     | 1000          | 1000              | 1000                  | 1000          | usasearch.gov |
    | Spanish     | 1000          | 1000              | 1000                  | 1000          | usasearch.gov |
    | Affiliates  | 1000          | 1000              | 1000                  | 1000          | usasearch.gov |
    And I am logged in with email "analyst@fixtures.org" and password "admin"
    When I am on the reports homepage
    Then I should see the header for the report date
    And I should see the "English" queries total within "english_usage_stats"
    And I should see the "English" page views total within "english_usage_stats"
    And I should see the "English" unique visitors total within "english_usage_stats"
    And I should see the "Spanish" queries total within "spanish_usage_stats"
    And I should see the "Spanish" page views total within "spanish_usage_stats"
    And I should see the "Spanish" unique visitors total within "spanish_usage_stats"
    And I should see the "Affiliates" queries total within "affiliates_usage_stats"
    And I should see the "Affiliates" page views total within "affiliates_usage_stats"
    And I should see the "Affiliates" unique visitors total within "affiliates_usage_stats"

  Scenario: Viewing Reports for a month in the past
    Given the following DailyUsageStats exist for each day in "2010-02"
    | profile | total_queries | total_page_views  | total_unique_visitors | affiliate     |
    | English | 1000          | 1000              | 1000                  | usasearch.gov |
    And I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the reports homepage
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then I should see the report header for "2010-02"
    And I should see the "English" "Queries" total within "english_usage_stats" with a total of "28,000"
    And I should see the "English" "Page Views" total within "english_usage_stats" with a total of "28,000"
    And I should see the "English" "Unique Visitors" total within "english_usage_stats" with a total of "28,000"

  Scenario: Viewing Reports for a month in the future
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyUsageStats exist for each day in "2019-02"
     | profile    | total_queries   | total_page_views  | total_unique_visitors | affiliate       |
     | English    | 1000            | 1000              | 1000                  | usasearch.gov   |
    And I am on the reports homepage
    And I select "December 2019" as the report date
    And I press "Get Usage Stats"
    Then I should see "Report information not available for the future."
