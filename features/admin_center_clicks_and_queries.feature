Feature: Clicks and Queries stats
  In order to see the correlation between user queries and clicked URLs
  As a site customer
  I want to see top clicked URLs, the queries that led to them, and the clicked URLs that came from those queries

  Scenario: Viewing the Site's Query Stats page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following DailyQueryStats exist for affiliate "aff.gov":
      | query          | times | day        |
      | pollution      | 100   | 2012-10-19 |
      | old pollution  | 10    | 2012-10-01 |
      | something else | 50    | 2012-10-18 |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Analytics page
    And I follow "Queries"
    Then I should see "Queries"
    And I should see the following table rows:
      | Top Queries     | # of Queries   |
      | pollution       | 100            |
      | something else  | 50             |
      | old pollution   | 10             |

    When I fill in "Query" with "pollute"
    And I fill in "From" with "2012-10-18"
    And I fill in "To" with "2012-10-19"
    And I press "Generate Report"
    Then I should see the following table rows:
      | Top Queries     | # of Queries   |
      | pollution       | 100            |

    When I fill in "Query" with "nothing to see here"
    And I fill in "From" with "2012-10-18"
    And I fill in "To" with "2012-10-19"
    And I press "Generate Report"
    Then I should see "Sorry, no results found for 'nothing to see here'"

  Scenario: Viewing the Site's Query Stats page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And there are no daily query stats
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Analytics page
    And I follow "Queries"
    Then I should see "Queries"
    And I should see "Your site has not received any search queries yet"

  Scenario: Viewing the Site's Click Stats page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following DailyClickStats:
      | url                     | times | day        |
      | http://www.aff.gov/url1 | 10    | 2012-10-19 |
      | http://www.aff.gov/url2 | 11    | 2012-10-19 |
      | http://www.aff.gov/url3 | 12    | 2012-10-19 |
      | http://www.aff.gov/url1 | 29    | 2012-10-18 |
      | http://www.aff.gov/url2 | 18    | 2012-10-18 |
      | http://www.aff.gov/url3 | 7     | 2012-10-18 |
    And affiliate "aff.gov" has the following QueriesClicksStats:
      | url                     | times | day        | query |
      | http://www.aff.gov/url1 | 5     | 2012-10-19 | foo   |
      | http://www.aff.gov/url2 | 50    | 2012-10-19 | foo   |
      | http://www.aff.gov/url1 | 4     | 2012-10-19 | bar   |
      | http://www.aff.gov/url1 | 2     | 2012-10-19 | blat  |
      | http://www.aff.gov/url1 | 15    | 2012-10-18 | foo   |
      | http://www.aff.gov/url2 | 25    | 2012-10-18 | foo   |
      | http://www.aff.gov/url1 | 2     | 2012-10-18 | bar   |
      | http://www.aff.gov/url1 | 1     | 2012-10-18 | baz   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Analytics page
    And I follow "Clicks"
    Then I should see "Clicks"
    And I should see the following table rows:
      | Top URLs Clicked | # of Clicks |
      | www.aff.gov/url1 | 39          |
      | www.aff.gov/url2 | 29          |
      | www.aff.gov/url3 | 19          |

    When I fill in "From" with "2012-10-19"
    And I fill in "To" with "2012-10-19"
    And I press "Generate Report"
    Then I should see the following table rows:
      | Top URLs Clicked | # of Clicks |
      | www.aff.gov/url3 | 12          |
      | www.aff.gov/url2 | 11          |
      | www.aff.gov/url1 | 10          |

    When I fill in "From" with "2012-10-18"
    And I fill in "To" with "2012-10-19"
    And I press "Generate Report"
    And I follow "39"
    Then I should see "Click Queries"
    And I should see "Top Queries leading to 'http://www.aff.gov/url1' from 2012-10-18 to 2012-10-19"
    And I should see the following table rows:
      | Top Queries | # of Clicks    |
      | foo         | 20             |
      | bar         | 6              |
      | blat        | 2              |
      | baz         | 1              |

    When I follow "20"
    Then I should see "Query Clicks"
    And I should see "Top Clicks on 'foo' from 2012-10-18 to 2012-10-19"
    And I should see the following table rows:
      | Top URLs Clicked | # of Clicks |
      | www.aff.gov/url2 | 75          |
      | www.aff.gov/url1 | 20          |
