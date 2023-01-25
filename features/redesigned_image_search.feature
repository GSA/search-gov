Feature: Image search - redesign
  In order to get government-related images
  As a site visitor
  I want to search for images on the redesigned Search page

  @javascript
  Scenario: English Image search
    Given the following Affiliates exist:
      | display_name | name   | contact_email | first_name | last_name | domains        |
      | USA.gov      | usagov | aff@bar.gov   | John       | Bar       | whitehouse.gov |
    When I am on usagov's redesigned image search page with "white house" query
    Then I should see 20 image results
