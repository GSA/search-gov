Feature: Trending URLs Snapshot
  In order to see which customer URLs are currently trending (via the Discovery Tag)
  As an Analyst
  I want to view currently trending URLs broken down by affiliate

  Scenario: Viewing the trending URLs page when data is available
    Given I am logged in with email "affiliate_admin@fixtures.org"
    And the following Affiliates exist:
    | name           | display_name     | contact_email | first_name | last_name |
    | aff1           | bureau.gov       | two@bar.gov   | Two        | Bar       |
    | aff2           | otheraff.govy    | two@bar.gov   | Two        | Bar       |
    And the following trending URLs exist:
    | affiliate_name | trending_urls                                                      |
    | aff1           | http://www.aff1.gov/url1.html,http://www.aff1.gov/url2.html        |
    | aff2           | http://www.aff2.gov/url3.html                                      |
    And the following hourly URL counts exist:
    | affiliate_name | hours_ago| count | url                           |
    | aff1           | 0        | 100   | http://www.aff1.gov/url1.html |
    | aff1           | 1        |   9   | http://www.aff1.gov/url1.html |
    | aff1           | 2        |   1   | http://www.aff1.gov/url1.html |
    | aff1           | 0        |  90   | http://www.aff1.gov/url2.html |
    | aff1           | 1        |   9   | http://www.aff1.gov/url2.html |
    | aff1           | 2        |   8   | http://www.aff1.gov/url2.html |
    | aff2           | 0        |  50   | http://www.aff2.gov/url3.html |
    | aff2           | 1        |   5   | http://www.aff2.gov/url3.html |
    | aff2           | 2        |   4   | http://www.aff2.gov/url3.html |
    When I am on the admin home page
    And I follow "Trending URLs"
    Then I should see "Trending URLs by Affiliate"
    And I should see the following table rows:
    | Affiliate      | URL                              | Current Rank | Average Rank   |  Historical Ranks |
    | bureau.gov     | http://www.aff1.gov/url1.html    | 1            | 2              |  2,2              |
    | bureau.gov     | http://www.aff1.gov/url2.html    | 2            | 1              |  1,1              |
    | otheraff.govy  | http://www.aff2.gov/url3.html    | 1            | 1              |  1,1              |

  Scenario: Viewing the trending URLs page when no data is available
    Given I am logged in with email "affiliate_admin@fixtures.org"
    And no trending URLs exist
    When I am on the admin home page
    And I follow "Trending URLs"
    Then I should see "No URLs are trending for any affiliate right now"
