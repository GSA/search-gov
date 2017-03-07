@vcr
Feature: Affiliate Search
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information

  Scenario: Search with a blank query on an affiliate page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    When I am on bar.gov's search page
    And I press "Search"
    Then I should see "Please enter a search term in the box above."

Scenario: Searching news items using time filters
    Given the following Affiliates exist:
      | display_name                 | name       | contact_email | contact_name | locale | youtube_handles |
      | bar site                     | bar.gov    | aff@bar.gov   | John Bar     | en     | en_agency       |
      | Spanish bar site             | es.bar.gov | aff@bar.gov   | John Bar     | es     | es_agency       |
    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    Then I should see "Everything"
    When I follow "Videos" in the search navbar
    Then I should see "Refine your search"
