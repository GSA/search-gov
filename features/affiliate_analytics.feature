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
    And the following NoResultsStats exist for affiliate "aff.gov":
      | query    | times  | day        |
      | nope 1   | 1110   | 2009-09-01 |
      | nope 2   | 111    | 2009-09-01 |
      | nope 3   | 1111   | 2009-09-01 |
      | nope 3   | 1112   | 2009-09-11 |
      | nope 4   | 1113   | 2009-09-11 |
    When I go to the affiliate admin page with "aff.gov" selected
    Then I should see "Site Analytics"
    When I follow "Query logs"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Query Analytics
    And I should see "Query Logs for aff site"
    And I should not see "aff.gov"
    And I should see "Most Popular Queries"
    And I should see the following table rows:
    | Query       | Frequency |
    | query 4     | 1113      |
    | query 3     | 1112      |
    And I should see "Queries with No Results"
    And I should see the following table rows:
    | Query       | Frequency |
    | nope 4      | 1113      |
    | nope 3      | 1112      |
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
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Query Search
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
      | total_queries | affiliate |
      | 1000          | aff.gov   |
    And the following DailySearchModuleStats exist for each day in yesterday's month
      | affiliate | total_clicks |
      | aff.gov   | 10           |
      | aff2.gov  | 5            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly reports"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Monthly Reports
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
      | total_queries | affiliate |
      | 1000          | aff.gov   |
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
      | total_queries | affiliate |
      | 1000          | aff.gov   |
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

  Scenario: Viewing the Affiliate's Click Stats page
    Given the following Affiliates exist:
      | display_name | name     | contact_email | contact_name |
      | aff site     | aff.gov  | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following DailyClickStats:
      | url                         | times |  day        |
      | http://www.aff.gov/url1     | 10    | 2012-10-19  |
      | http://www.aff.gov/url2     | 11    | 2012-10-19  |
      | http://www.aff.gov/url3     | 12    | 2012-10-19  |
      | http://www.aff.gov/url1     | 29    | 2012-10-18  |
      | http://www.aff.gov/url2     | 18    | 2012-10-18  |
      | http://www.aff.gov/url3     |  7    | 2012-10-18  |
    And affiliate "aff.gov" has the following QueriesClicksStats:
      | url                         | times |  day        |  query    |
      | http://www.aff.gov/url1     | 5     | 2012-10-19  |  foo      |
      | http://www.aff.gov/url2     | 50    | 2012-10-19  |  foo      |
      | http://www.aff.gov/url1     | 4     | 2012-10-19  |  bar      |
      | http://www.aff.gov/url1     | 2     | 2012-10-19  |  blat     |
      | http://www.aff.gov/url1     | 15    | 2012-10-18  |  foo      |
      | http://www.aff.gov/url2     | 25    | 2012-10-18  |  foo      |
      | http://www.aff.gov/url1     | 2     | 2012-10-18  |  bar      |
      | http://www.aff.gov/url1     | 1     | 2012-10-18  |  baz      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Click stats"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Top Clicked URLs
    And I should see "Click Stats for aff site"
    And I should see "Most Popular URLs"
    And I should see the following table rows:
      | URL                       | Clicks |
      | http://www.aff.gov/url3   | 12     |
      | http://www.aff.gov/url2   | 11     |
      | http://www.aff.gov/url1   | 10     |

    When I fill in "start_date" with "2012-10-18"
    And I fill in "end_date" with "2012-10-19"
    And I press "Submit"
    Then I should see the following table rows:
      | URL                       | Clicks |
      | http://www.aff.gov/url1   | 39     |
      | http://www.aff.gov/url2   | 29     |
      | http://www.aff.gov/url3   | 19     |

    When I follow "View top query terms leading to this URL"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Click Queries
    And I should see "Top Queries leading to 'http://www.aff.gov/url1' for aff site from 2012-10-18 to 2012-10-19"
    And I should see the following table rows:
      | Query       | Total |
      | foo         | 20    |
      | bar         | 6     |
      | blat        | 2     |
      | baz         | 1     |

    When I follow "View top clicked URLs for this query term"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Query Clicks
    And I should see "Top Clicks on 'foo' for aff site from 2012-10-18 to 2012-10-19"
    And I should see the following table rows:
      | URL                       | Total  |
      | http://www.aff.gov/url2   | 75     |
      | http://www.aff.gov/url1   | 20     |

  Scenario: Viewing trending queries for an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist:
      | query    | times  | days_back  | affiliate |
      | missing  | 1110   |   2        | aff.gov   |
      | valid but "weird" | 111    |   2        | aff.gov   |
      | trending | 111    |   2        | aff.gov   |
      | downer   | 111    |   2        | aff.gov   |
      | valid but "weird" | 1111   |   1        | aff.gov   |
      | trending | 1111   |   1        | aff.gov   |
      | new one  | 1112   |   1        | aff.gov   |
      | downer   | 110    |   1        | aff.gov   |
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Trending queries"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Trending Queries
    And I should see "Trending Queries for aff site over the past day or so"
    And I should see the following table rows:
      | Query       | Twitter  | News |
      | new one     |          |      |
      | trending    |          |      |
    And I should not see "valid but"

  Scenario: When no trending queries exist for an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist:
      | query    | times  | days_back  | affiliate |
      | missing  | 1110   |   2        | aff.gov   |
      | downer   | 111    |   2        | aff.gov   |
      | downer   | 110    |   1        | aff.gov   |
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Trending queries"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Trending Queries
    And I should see "Trending Queries for aff site over the past day or so"
    And I should see "No queries meet the criteria for trending queries right now."

  Scenario: Viewing low CTR queries for an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist:
      | query    | times  | days_back  | affiliate |
      | zero ctr | 1110   |   1        | aff.gov   |
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Low CTR queries"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Low Click-Thru Rate (CTR) Queries
    And I should see "Queries with low click-thru rates for aff site over the past day or so"
    And I should see the following table rows:
      | Query       | CTR%     |
      | zero ctr    |   0%     |

  Scenario: When no low CTR queries exist for an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist:
      | query    | times  | days_back  | affiliate |
      | doesn't qualify  | 1110   |   2        | aff.gov   |
      | nor this: one   | 111    |   2        | aff.gov   |
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Low CTR queries"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Low Click-Thru Rate (CTR) Queries
    And I should see "Queries with low click-thru rates for aff site over the past day or so"
    And I should see "No queries meet the criteria for low click-thru rate queries right now."

  Scenario: Viewing the Affiliate's Page Views page
    Given the following Affiliates exist:
      | display_name | name     | contact_email | contact_name |
      | aff site     | aff.gov  | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | name          | url                                                | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press               | true         |
    And affiliate "aff.gov" has the following document collections:
      | name | prefixes             | is_navigable |
      | FAQs | http://aff.gov/faqs/ | true         |
    And affiliate "aff.gov" has the following DailyLeftNavStats:
      | search_type    | total | params | days_back |
      | /search        | 100   |        | 1         |
      | /search        | 100   |        | 2         |
      | /search        | 1000  |        | 30        |
      | /search/images | 10    |        | 3         |
      | /search/news   | 11    | NULL:y | 3         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Page views"
    And I fill in "start_date" with a date representing "29" days ago
    And I fill in "end_date" with a date representing "1" day ago
    And I press "Submit"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Page Views
    And I should see "Page Views for aff site"
    And I should see "Web: 200"
    And I should see "Images: 10"
    And I should see "Last Year: 11"

    When I fill in "start_date" with a date representing "59" days ago
    And I fill in "end_date" with a date representing "59" day ago
    And I press "Submit"
    Then I should see "No data is available for this date range"
