Feature: Image search
  In order to get government-related images
  As a site visitor
  I want to search for images

  Scenario: English Image search
    Given the following Affiliates exist:
      | display_name | name   | contact_email | first_name | last_name | header         | domains        |
      | USA.gov      | usagov | aff@bar.gov   | John       | Bar       | USA.gov Header | whitehouse.gov |
    When I am on usagov's image search page
    When I search for "White House"
    Then I should see the browser page titled "White House - USA.gov Search Results"
    And I should see 20 image results
    And I should see Powered by Bing logo

  Scenario: Image search with spelling suggestion
    Given the following Affiliates exist:
      | display_name | name   | contact_email | first_name | last_name |
      | USA.gov      | usagov | aff@bar.gov   | John       | Bar       |
    And the following Suggestion Blocks exist:
      | query |
      | ebuy  |
    When I am on usagov's image search page
    When I fill in "query" with "ebuy"
    And I press "Search"
    Then I should not see "Showing results for ebay"

  Scenario: Spanish image search
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | first_name | last_name | header                  | locale |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John       | Bar       | Gobierno.USA.gov Header | es     |
    When I am on gobiernousa's image search page
    When I fill in "query" with "Barcelona"
    And I press "Buscar"
    And I should see the browser page titled "Barcelona - GobiernoUSA.gov resultados de la búsqueda"
    And I should see 20 image results
