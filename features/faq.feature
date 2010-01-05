Feature: FAQ
  In order to understand the analytics data better
  As an Analyst
  I want to view a page containing hypothetical FAQ's and their answers

  Scenario: Visiting the FAQ page
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And I am on the analytics homepage
    When I follow "FAQ"
    Then I should be on the FAQ page
    And I should see "Frequently Asked Questions about Analytics"