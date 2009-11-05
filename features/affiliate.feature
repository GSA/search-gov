Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    Given the following Affiliates exist:
    | name        |
    | noaa.gov    |
    | ct.gov      |
    When I go to the affiliate list page
    Then I should see "noaa.gov"
    And I should see "ct.gov"
    When I follow "noaa.gov"
    Then I should land on noaa.gov's search page 
