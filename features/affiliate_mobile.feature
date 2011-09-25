Feature: Mobile Search for Affiliate
  In order to get affiliate-related information on my mobile device
  As a mobile device user
  I want to be able to search with a streamlined interface

  Background:
    Given I am using a mobile device

  Scenario: A search on affiliate
    Given the following Affiliates exist:
      | display_name | name       | contact_email  | contact_name | domains | header           | footer           |
      | agency site  | agency.gov | aff@agency.gov | John Bar     |         | Affiliate Header | Affiliate Footer |
    And the following Boosted Content entries exist for the affiliate "agency.gov"
      | title              | url                       | description                          |
      | Our Emergency Page | http://www.agency.gov/911 | Updated information on the emergency |
      | FAQ Emergency Page | http://www.agency.gov/faq | More information on the emergency    |
      | Our Tourism Page   | http://www.agency.gov/tou | Tourism information                  |
    And I am on agency.gov's mobile search page
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see the browser page titled "agency site Mobile"
    And I should see "agency site Mobile" in the mobile page header
    When I fill in "query" with "emergency"
    And I submit the search form
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see the browser page titled "agency site Mobile"
    And I should see "Our Emergency Page" in the mobile boosted contents section
    When I follow "Next"
    Then I should not see "Our Emergency Page"

  Scenario: Toggling back to classic mode
    Given the following Affiliates exist:
      | display_name | name       | contact_email  | contact_name | domains | header           | footer           |
      | agency site  | agency.gov | aff@agency.gov | John Bar     |         | Affiliate Header | Affiliate Footer |
    And I am on agency.gov's mobile search page
    And I fill in "query" with "social security"
    And I submit the search form
    Then I should see the browser page titled "agency site Mobile"
    When I follow "Classic"
    Then I should see the browser page titled "social security - agency site Search Results"

