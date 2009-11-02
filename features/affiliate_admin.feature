Feature: Affiliate Administration
  In order to see who is using USASearch as an Affiliate and manage their accounts
  As an administrator
  I want to see relevant information for all Affiliates

  Scenario: Visiting the affiliate admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And "affiliate_admin@fixtures.org" is an affiliate administrator
    When I go to the affiliate admin home page
    Then I should see "Affiliates"
    And I should see "affiliate_admin@fixtures.org"
    And I should see "My Account"
    And I should see "Logout"
    When I follow "Logout"
    Then I should be on the login page
