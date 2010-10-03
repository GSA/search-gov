Feature: Weather Spotlight
  In order to view local weather forecasts
  As a site visitor
  I want to be able to view local weather forecasts from the search interface
  
  Scenario: Searching for weather by zip code
    Given the following Locations exist:
    | zip_code  | state | city      | population  | lat     | lng       |
    | 21209     | MD    | Baltimore | 20675       | 39.3716 | -76.6744  |
    And I am on the homepage
    And I fill in "query" with "weather 21209"
    And I press "Search"
    Then I should be on the search page
    And I should see "National Weather Service Forecast for Baltimore, MD"

    