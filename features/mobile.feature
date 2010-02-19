Feature: Mobile Search
  In order to get government-related information on my mobile device
  As a mobile device user
  I want to be able to search with a streamlined interface

  Background:
    Given I am using a mobile device

  Scenario: Visiting the home page from a desktop browser
    Given I am using a desktop device
    And I am on the homepage
    Then I should see "Mobile"

  Scenario: Visiting the home page with a mobile device
    Given I am on the homepage
    Then I should see "Full Site"

  Scenario: Toggling full mode
    Given I am on the homepage
    When I follow "Full Site"
    Then I should be on the homepage
    And I should see "Mobile"

  Scenario: Toggling back to mobile mode
    Given I am on the homepage
    When I follow "Full Site"
    And I follow "Mobile"
    Then I should be on the homepage
    And I should see "Full Site"

  Scenario: Using mobile mode with a brower not identified as mobile
    Given I am using a desktop device
    And I am on the homepage
    When I follow "Mobile"
    Then I should see "Full Site"

  Scenario: A search on the mobile home page
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should see "social security"
    And I should see 3 search results
