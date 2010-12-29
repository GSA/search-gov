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

  Scenario: Affiliate admin should be on the affiliate home page upon successful login
    Given I am on the login page
    And I fill in "Email address" with "affiliate_admin@fixtures.org"
    And I fill in "Password" with "admin"
    And I press "Login"
    Then I should be on the affiliate admin page
    And I should see "Admin Center"

  Scenario: Analyst should be on the analytics homepage upon successful login
    Given I am on the login page
    And I fill in "Email address" with "analyst@fixtures.org"
    And I fill in "Password" with "admin"
    And I press "Login"
    Then I should be on the analytics homepage
    And I should see "Analyst Center"

  Scenario: Affiliate manager should be on the affiliate home page upon successful login
    Given I am on the login page
    And I fill in "Email address" with "affiliate_manager@fixtures.org"
    And I fill in "Password" with "admin"
    And I press "Login"
    Then I should be on the affiliate admin page
    And I should see "Affiliate Center"
