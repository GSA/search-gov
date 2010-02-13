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

  Scenario: A search on the mobile home page using an iPhone
    Given I am using an iPhone device
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should see 10 search results

  Scenario: A nonsense search from the mobile home page
    Given I am on the homepage
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search from the home page
    Given I am on the homepage
    When I submit the search form
    Then I should be on the search page
    And I should see "Please enter search term(s)"

  Scenario: A really long search from the home page
    Given I am on the homepage
    When I fill in "query" with a 10000 character string
    And I submit the search form
    Then I should see "That is too long a word. Try using a shorter word."
