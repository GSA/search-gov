Feature: Monthly Reports
  In order to generate monthly reports on monthly site and search activity
  As an Analyst
  I want to view the total number of queries,
    the total number of unique site visitors,
    the total number of page views,
    the total number of click throughs, impressions, and the click-thru rate,
    the most popular queries for English locale and default affiliate,
    and the most popular query groups for English locale and default affiliate.

  Scenario: Viewing module click stats on the the Reports homepage
    Given the following search modules exist:
    | tag | display_name |
    | FOO | Foo Module   |
    | BAR | Bar Module   |
    And the following search module data exists for "2011-06-10":
    | affiliate_name | module_tag     | vertical| locale | impressions | clicks |
    | usasearch.gov  | FOO            | web     | en     | 100         | 40     |
    | usasearch.gov  | BAR            | web     | en     | 10          | 9      |
    | usasearch.gov  | FOO            | form    | en     | 10          | 1      |
    | usasearch.gov  | FOO            | image   | es     | 10          | 2      |
    | otheraff.govy  | BAR            | web     | en     | 10          | 3      |
    | otheraff.govy  | UNKNOWN        | recall  | en     | 1           | 1      |
    And the following search module data exists for "2011-03-01":
    | affiliate_name | module_tag     | vertical| locale | impressions | clicks |
    | usasearch.gov  | FOO            | web     | en     | 100         | 40     |
    | usasearch.gov  | BAR            | web     | en     | 10          | 9      |
    | usasearch.gov  | FOO            | form    | en     | 10          | 1      |
    | usasearch.gov  | FOO            | image   | es     | 10          | 2      |
    | otheraff.govy  | BAR            | web     | en     | 10          | 3      |
    | otheraff.govy  | UNKNOWN        | recall  | en     | 1           | 1      |
    And the following search module data exists for "2011-03-30":
    | affiliate_name | module_tag     | vertical| locale | impressions | clicks |
    | usasearch.gov  | FOO            | web     | en     | 100         | 40     |
    | usasearch.gov  | BAR            | web     | en     | 10          | 9      |
    | usasearch.gov  | FOO            | form    | en     | 10          | 1      |
    | usasearch.gov  | FOO            | image   | es     | 10          | 2      |
    | otheraff.govy  | BAR            | web     | en     | 10          | 3      |
    | otheraff.govy  | UNKNOWN        | recall  | en     | 1           | 1      |

    And I am logged in with email "analyst@fixtures.org" and password "admin"
    When I am on the analytics homepage
    And I follow "Monthly Reports"
    Then I should see the following breadcrumbs: USASearch > Analytics Center > Monthly Reports

    When I select "June 2011" as the report date
    And I press "Get Usage Stats"
    Then I should see "Impressions and Clicks by Module"
    And I should see the following table rows:
    | Module      | Impressions     | Clicks | Clickthru Rate   |
    | Foo Module  | 120             | 43     | 35.8%            |
    | Bar Module  | 20              | 12     | 60.0%            |

    When I select "March 2011" as the report date
    And I press "Get Usage Stats"
    Then I should see the following table rows:
    | Module      | Impressions     | Clicks | Clickthru Rate   |
    | Foo Module  | 240             | 86     | 35.8%            |
    | Bar Module  | 40              | 24     | 60.0%            |

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
