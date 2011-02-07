Feature: Widgets

  Scenario: Visiting trending searches widget page
    Given the following Top Searches exist:
    | position  | query              |
    | 1         | Trending Search 1  |
    | 2         | Trending Search 2  |
    | 3         | Trending Search 3  |
    | 4         | Trending Search 4  |
    | 5         | Trending Search 5  |
    And I am on the trending searches page
    Then I should see "Search Trends"
    And I should see "Trending Search 1"
    And I should see "Trending Search 2"
    And I should see "Trending Search 3"
    And I should see "Trending Search 4"
    And I should not see "Trending Search 5"

