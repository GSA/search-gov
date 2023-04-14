Feature: Image search - redesign
  In order to get government-related images
  As a site visitor
  I want to search for images on the redesigned Search page

  @javascript @a11y @a11y_wip
  Scenario: English Image search
    Given the following Affiliates exist:
      | display_name | name   | contact_email | first_name | last_name | domains        |
      | USA.gov      | usagov | aff@bar.gov   | John       | Bar       | whitehouse.gov |
    When I am on usagov's redesigned image search page
    And I search for "white house" in the redesigned search page
    Then I should see 20 image results
