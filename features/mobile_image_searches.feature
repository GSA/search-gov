Feature: Image search using mobile template
  In order to get government-related images
  As a site visitor
  I want to search for images

  Background:
    Given I am using a mobile device

  Scenario: English Image search on a legacy site
    Given the following legacy Affiliates exist:
      | display_name      | name     | contact_email | first_name | last_name | is_image_search_navigable |
      | USA.gov           | usagov   | aff@bar.gov   | John       | Bar       | true                      |
    When I am on usagov's search page
    And I fill in "Enter your search term" with "sunset"
    And I press "Search"
    And I follow "Images" within the SERP navigation
    Then I should see exactly "20" image search results
    And I should see "Powered by Bing"
