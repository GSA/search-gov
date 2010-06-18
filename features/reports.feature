Feature: Reports
  In order to generate reports on site and search activity
  As an Analyst
  I want to view data on site and search activity.  The data consists of the total number of queries,
    total number of unique site visitors, total number of page views and total number of click throughs,
    and can be broken down according to the English, Spanish and Affiliate views of the site, and is available
    by a monthly timeframe

  Scenario: Viewing module click stats on the the Reports homepage
    Given the following Clicks per module exist in "February 2010"
    | module  | total |
    | FORM    | 4     |
    | FAQS    | 3     |
    And the following Clicks per module exist in "March 2010"
    | module  | total |
    | BWEB    | 2     |
    | BREL    | 1     |
    And I am logged in with email "analyst@fixtures.org" and password "admin"
    When I am on the reports homepage
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then in "module_click_stats" I should see "FORM"
    And in "module_click_stats" I should see "4"
    And in "module_click_stats" I should see "FAQS"
    And in "module_click_stats" I should see "3"
    When I select "March 2010" as the report date
    And I press "Get Usage Stats"
    Then in "module_click_stats" I should see "BWEB"
    And in "module_click_stats" I should see "2"
    And in "module_click_stats" I should see "BREL"
    And in "module_click_stats" I should see "1"

  Scenario: Viewing DailyUsageStats on the the Reports homepage
    Given the following DailyUsageStats exists for each day in the current month
    | profile     | total_queries | total_page_views  | total_unique_visitors | total_clicks  | affiliate     |
    | English     | 1000          | 1000              | 1000                  | 1000          | usasearch.gov |
    | Spanish     | 1000          | 1000              | 1000                  | 1000          | usasearch.gov |
    | Affiliates  | 1000          | 1000              | 1000                  | 1000          | usasearch.gov |
    And I am logged in with email "analyst@fixtures.org" and password "admin"
    When I am on the reports homepage
    Then I should see the header for the current date
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
    | profile | total_queries | total_page_views  | total_unique_visitors | total_clicks  | affiliate     |
    | English | 1000          | 1000              | 1000                  | 1000          | usasearch.gov |
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
    And I am on the reports homepage
    And I select "December 2010" as the report date
    And I press "Get Usage Stats"
    Then I should see "Report information not available for the future."