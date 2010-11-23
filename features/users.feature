Feature: Users

  Scenario: Logged-in user visits account page
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    Then I should see "API Key"
    And I should see "Your API key is:"
    And I should see "Account Profile"
    And I should see "Email"
    And I should see "Contact Name"
    And I should see "Time Zone"
    And I should see "Phone"
    And I should see "Organization Name"
    And I should see "Address"
    And I should see "Address Line 2"
    And I should see "City"
    And I should see "State"
    And I should see "Zip"

  Scenario: Registering as a new affiliate user
    Given I am on the new user page
    And I fill in the following:
    | Contact Name                  | Lorem Ipsum                 |
    | Email                         | lorem.ipsum@agency.gov      |
    | Phone                         | 301.123.4567                |
    | Organization name             | The Agency                  |
    | Organization address          | 123 Penn Ave                |
    | Address Line 2                | Ste 456                     |
    | City                          | Reston                      |
    | Zip                           | 20022                       |
    | Enter password                | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I select "Virginia" from "State"
    And I select "(GMT-05:00) Eastern Time (US & Canada)" from "Time Zone"
    And I press "Register"
    Then I should be on the user account page
    And I should see "Thank you for registering for USA.gov Search Services"
    And I should see "You currently have no affiliates"

  Scenario: Registering as a new affiliate user with a .mil email address
    Given I am on the new user page
    And I fill in the following:
    | Contact Name                  | Lorem Ipsum                 |
    | Email                         | lorem.ipsum@agency.mil      |
    | Phone                         | 301.123.4567                |
    | Organization name             | The Agency                  |
    | Organization address          | 123 Penn Ave                |
    | Address Line 2                | Ste 456                     |
    | City                          | Reston                      |
    | Zip                           | 20022                       |
    | Enter password                | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I select "Virginia" from "State"
    And I select "(GMT-05:00) Eastern Time (US & Canada)" from "Time Zone"
    And I press "Register"
    Then I should be on the user account page
    And I should see "Thank you for registering for USA.gov Search Services"
    And I should see "You currently have no affiliates"

  Scenario: Failing registration as a new affiliate user
    Given I am on the new user page
    And I press "Register"
    Then I should be on the user account page
    And I should see "can't be blank"