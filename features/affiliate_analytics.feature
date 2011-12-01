Feature: Affiliate analytics
  In order to understand the query trends of my users
  As an affiliate
  I want to see popular queries, trending queries, monthly summaries, and be able to search and report on query terms and patterns

  Scenario: Getting stats for an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist for affiliate "aff.gov":
      | query    | times  | day        |
      | query 1  | 1110   | 2009-09-01 |
      | query 2  | 111    | 2009-09-01 |
      | query 3  | 1111   | 2009-09-01 |
      | query 3  | 1112   | 2009-09-11 |
      | query 4  | 1113   | 2009-09-11 |
    When I go to the affiliate admin page with "aff.gov" selected
    Then I should see "Site Analytics"
    When I follow "Query logs"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Query Analytics
    And I should see "Query Logs for aff site"
    And I should not see "aff.gov"
    And I should see "Most Popular Queries"
    And I should see the following table rows:
    | Query       | Frequency |
    | query 4     | 1113      |
    | query 3     | 1112      |
    And I should not see "No queries matched"

  Scenario: No daily query stats available for any time period
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there are no daily query stats
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query logs"
    Then I should see "Not enough historic data"

  Scenario: Viewing Query Search page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following DailyQueryStats exist:
      | query         | times | affiliate     | locale | days_back |
      | pollution     | 100   | aff.gov       | en     | 1         |
      | old pollution | 10    | aff.gov       | en     | 30        |
      | pollutant     | 90    | usasearch.gov | en     | 1         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query logs"
    And I fill in "query" with "pollution"
    And I fill in "analytics_search_start_date" with a date representing "29" days ago
    And I fill in "analytics_search_end_date" with a date representing "1" day ago
    And I press "Search"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Query Search
    And I should see "Matches for 'pollution'"
    And I should not see "Matches for 'old pollution'"
    And I should not see "Matches for 'pollutant'"
    And I should not see "aff.gov"

  Scenario: Viewing the Affiliates Monthly Reports page
    Given the following Affiliates exist:
      | display_name | name     | contact_email | contact_name |
      | aff site     | aff.gov  | aff@bar.gov   | John Bar     |
      | aff2 site    | aff2.gov | aff@bar.gov   | John Bar     |
    And the following DailyUsageStats exists for each day in yesterday's month
      | profile    | total_queries | affiliate |
      | Affiliates | 1000          | aff.gov   |
    And the following DailySearchModuleStats exist for each day in yesterday's month
      | affiliate | total_clicks |
      | aff.gov   | 10           |
      | aff2.gov  | 5            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly reports"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Monthly Reports
    And I should see "Monthly Reports for aff site"
    And I should see "Monthly Usage Stats"
    And I should not see "aff.gov"
    And I should see the header for the report date
    And I should see the "aff site" queries total within "aff.gov_usage_stats"
    And I should see the "aff site" clicks total within "aff.gov_usage_stats"

  Scenario: Viewing the Affiliates Monthly Reports page for a month in the past
    Given the following Affiliates exist:
      | display_name | name     | contact_email | contact_name |
      | aff site     | aff.gov  | aff@bar.gov   | John Bar     |
      | aff2 site    | aff2.gov | aff@bar.gov   | John Bar     |
    And the following DailyUsageStats exist for each day in "2010-02"
      | profile    | total_queries | affiliate |
      | Affiliates | 1000          | aff.gov   |
    And the following DailySearchModuleStats exist for each day in "2010-02"
      | affiliate | total_clicks |
      | aff.gov   | 10           |
      | aff2.gov  | 5            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly reports"
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then I should see the report header for "2010-02"
    And I should see the "aff site" "Queries" total within "aff.gov_usage_stats" with a total of "28,000"
    And I should see the "aff site" "Click Throughs" total within "aff.gov_usage_stats" with a total of "280"

  Scenario: Viewing the Affiliates Monthly Reports page for a month in the future
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following DailyUsageStats exist for each day in "2021-02"
      | profile    | total_queries | affiliate |
      | Affiliates | 1000          | aff.gov   |
    And the following DailySearchModuleStats exist for each day in "2021-02"
      | affiliate | total_clicks |
      | aff.gov   | 10           |
      | aff2.gov  | 5            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly reports"
    And I select "December 2019" as the report date
    And I press "Get Usage Stats"
    Then I should see "Report information not available for the future."
