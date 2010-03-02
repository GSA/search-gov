Feature: Reports
  In order to generate reports on site and search activity
  As an Analyst
  I want to view data on site and search activity.  The data consists of the total number of queries, 
    total number of unique site visitors, total number of page views and total number of click throughs,
    and can be broken down according to the English, Spanish and Affiliate views of the site, and is available
    by a monthly timeframe

  Scenario: Viewing the Reports homepage
    Given the following DailyUsageStats exists for each day in the current month
    | profile     | total_queries | total_page_views  | total_unique_visitors | total_clicks  |
    | English     | 1000          | 1000              | 1000                  | 1000          |
    | Spanish     | 1000          | 1000              | 1000                  | 1000          |
    | Affiliates  | 1000          | 1000              | 1000                  | 1000          |
    And I am logged in with email "analyst@fixtures.org" and password "admin"
    When I am on the reports homepage
    Then I should see the header for the current date
    And I should see the "English" queries total within "english_usage_stats"
    And I should see the "English" page views total within "english_usage_stats"
    And I should see the "English" unique visitors total within "english_usage_stats"
    And I should see the "English" clicks total within "english_usage_stats"
    And I should see the "Spanish" queries total within "spanish_usage_stats"
    And I should see the "Spanish" page views total within "spanish_usage_stats"
    And I should see the "Spanish" unique visitors total within "spanish_usage_stats"
    And I should see the "Spanish" clicks total within "spanish_usage_stats"
    And I should see the "Affiliates" queries total within "affiliates_usage_stats"
    And I should see the "Affiliates" page views total within "affiliates_usage_stats"
    And I should see the "Affiliates" unique visitors total within "affiliates_usage_stats"
    And I should see the "Affiliates" clicks total within "affiliates_usage_stats"
    
  Scenario: Viewing Reports for a month in the past
    Given the following DailyUsageStats exist for each day in "2010-02"
    | profile | total_queries | total_page_views  | total_unique_visitors | total_clicks  |
    | English | 1000          | 1000              | 1000                  | 1000          |
    And I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the reports homepage
    And I select "February 1, 2010" as the report date  
    And I press "Get Usage Stats"
    Then I should see the report header for "2010-02"
    And I should see the "English" "Queries" total within "english_usage_stats" with a total of "28,000"
    And I should see the "English" "Page Views" total within "english_usage_stats" with a total of "28,000"
    And I should see the "English" "Unique Visitors" total within "english_usage_stats" with a total of "28,000"
    And I should see the "English" "Click Throughs" total within "english_usage_stats" with a total of "28,000"

  Scenario: Viewing Reports for a month in the future
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the reports homepage
    And I select "December 2010" as the report date  
    And I press "Get Usage Stats"
    Then I should see "Report information not available for the future."   
  