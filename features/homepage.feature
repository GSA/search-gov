Feature: Homepage
  In order to get government-related information
  As a site visitor
  I want to be able to search for information

  Scenario: A typical popular search from the home page
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should see "Results 1-10"
    And I should see "social security"
    And I should see 10 search results
    And I should see "Next »"

  Scenario: A nonsense search from the home page
    Given I am on the homepage
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search from the home page
    Given I am on the homepage
    When I submit the search form
    Then I should be on the search page
    And I should see "Please enter search term(s)"

  Scenario: A unicode search from the home page
    Given I am on the homepage
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "White House"

  Scenario: A really long search from the home page
    Given I am on the homepage
    When I fill in "query" with a 10000 character string
    And I submit the search form
    Then I should see "That is too long a word. Try using a shorter word."