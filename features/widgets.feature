Feature: Widgets

  Scenario: Visiting trending searches widget page
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | top_searches_label | header         |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | Top Searches       | USA.gov Header |
    Given the following Top Searches exist:
      | position | query             | affiliate_name |
      | 1        | White House       | usagov         |
      | 2        | Trending Search 2 | usagov         |
      | 3        | Trending Search 3 | usagov         |
      | 4        | Trending Search 4 | usagov         |
      | 5        |                   | usagov         |
    And I am on the trending searches page
    Then I should see "Top Searches"
    And I should see 4 search trends
    And I should see "White House"
    And I should see "Trending Search 2"
    And I should see "Trending Search 3"
    And I should see "Trending Search 4"
    When I follow "White House"
    Then I should see "USA.gov Header"
    And I should see at least 8 search results

  Scenario: Visiting trending searches widget for an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | top_searches_label  | header          |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | Top Searches        | Bar.gov Header  |
    And the following Top Searches exist:
      | position  | query         | url                 | affiliate_name  |
      | 1         | Top Search 1  |                     | aff.gov         |
    And I am on aff.gov's trending searches page
    Then I should not see "Search Trends"
    And I should see "Top Searches"
    And I should see "Top Search 1"
    When I follow "Top Search 1"
    Then I should see "Bar.gov Header"
