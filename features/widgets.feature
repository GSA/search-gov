Feature: Widgets

  Scenario: Visiting trending searches widget page
    Given the following Top Searches exist:
    | position  | query              |
    | 1         | White House        |
    | 2         | Trending Search 2  |
    | 3         | Trending Search 3  |
    | 4         | Trending Search 4  |
    | 5         |                    |
    And I am on the trending searches page
    Then I should see "Search Trends"
    And I should see 4 search trends
    And I should see "White House"
    And I should see "Trending Search 2"
    And I should see "Trending Search 3"
    And I should see "Trending Search 4"
    When I follow "White House"
    Then I should be on the search page
    And I should see 10 search results

  Scenario: Visiting top searches widget page
    Given the following Top Searches exist:
    | position  | query              |
    | 1         | White House        |
    | 2         | Trending Search 2  |
    | 3         | Trending Search 3  |
    | 4         | Trending Search 4  |
    | 5         |                    |
    And I am on the top searches widget page
    Then I should see "TOP SEARCHES"
    And I should see 4 top searches
    And I should see "White House"
    And I should see "Trending Search 2"
    And I should see "Trending Search 3"
    And I should see "Trending Search 4"
    When I follow "White House"
    Then I should be on the search page
    And I should see 10 search results
