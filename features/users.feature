Feature: Users

  Scenario: Logged-in user visits account page
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    Then I should see "Account Profile"
    And I should see "Email"
    And I should see "Contact Name"
    And I should see "Time Zone"
