Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    Given the following Affiliates exist:
    | name        | contact_name      | contact_email     |
    | nasa.gov    | John Doe          | john@agency.gov   |
    | ct.gov      | Jane Doe          | jane@agency.gov   |
    When I go to the affiliate list page
    Then I should see "nasa.gov"
    And I should see "ct.gov"
    And I should see "John Doe"
    And I should see "Jane Doe"
    And I should see "john@agency.gov"
    And I should see "jane@agency.gov"
    When I follow "nasa.gov"
    Then I should land on nasa.gov's search page
