Feature: Homepage
  In order to use the USASearch.gov website
  As a viewer
  I want to see a well-designed homepage with a search box

  Scenario: A typical popular search from the home page
    Given I am on the homepage
    When I fill in "queryterm" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should see "Results 1-8"
    And I should see "social security"
    And I should see 8 search results
    And I should see "Next »"

  Scenario: A nonsense search from the home page
    Given I am on the homepage
    When I fill in "queryterm" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search from the home page
    Given I am on the homepage
    When I submit the search form
    Then I should be on the search page
    And I should see "Please enter search term(s)"
