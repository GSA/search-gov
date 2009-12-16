Feature: User sessions

  Scenario: Already logged-in user visits login page
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the login page
    Then I should be on the user account page

  Scenario: User has trouble logging in
    Given I am on the login page
    And I fill in "Email address" with "not@valid.gov"
    And I fill in "Password" with "fail"
    And I press "Login"
    Then I should see "Email is not valid"