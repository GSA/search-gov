Feature: Analytics Homepage
  In order to anticipate trends and topics of high public interest
  As an Analyst
  I want to view analytics on usasearch query data. The analytics contains most popular queries, and
    queries getting no results in the web vertical (if any exist).

  Scenario: Viewing the homepage
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist for affiliate "usasearch.gov":
      | query    | times  | day        |
      | query 1  | 1110   | 2009-09-01 |
      | query 2  | 111    | 2009-09-01 |
      | query 3  | 1111   | 2009-09-01 |
      | query 3  | 1112   | 2009-09-11 |
      | query 4  | 1113   | 2009-09-11 |
    And the following NoResultsStats exist for affiliate "usasearch.gov":
      | query           | times  | day        |
      | gobbledegook 1  | 101    | 2009-09-01 |
      | gobbledegook 2  | 102    | 2009-09-01 |
      | gobbledegook 1  | 103    | 2009-09-11 |
      | gobbledegook 3  | 104    | 2009-09-11 |
    When I am on the analytics homepage
    Then I should see "Analytics Center" link in the main navigation bar
    And I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center
    When I follow "Analytics Center" in the main navigation bar
    Then I should be on the analytics homepage
    When I follow "Queries"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center > Queries
    And I should see "No Results Queries"
    And I should see the following table rows:
    | Query           | Frequency |
    | gobbledegook 3  | 104       |
    | gobbledegook 1  | 103       |
    And I should see "Most Popular Queries"
    And I should see the following table rows:
    | Query       | Frequency |
    | query 4     | 1113      |
    | query 3     | 1112      |
    When I fill in "start_date" with "2009-09-01"
    And I fill in "end_date" with "2009-09-11"
    And I press "Submit"
    Then I should see "Most Popular Queries"
    And I should see the following table rows:
    | Query       | Frequency |
    | query 3     | 2223      |
    | query 4     | 1113      |
    | query 1     | 1110      |
    | query 2     | 111       |
    And I should see "No Results Queries"
    And I should see the following table rows:
    | Query           | Frequency |
    | gobbledegook 1  | 204       |
    | gobbledegook 3  | 104       |
    | gobbledegook 2  | 102       |
    When I follow "query 3"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center > Query Timeline

  Scenario: No daily query stats available for any time period
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no daily query stats
    When I am on the analytics homepage
    And I follow "Queries"
    Then I should see "Not enough historic data"

  Scenario: No zero-result queries available
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And there are no zero result query stats
    When I am on the analytics homepage
    And I follow "Queries"
    Then I should not see "No Results Queries"
