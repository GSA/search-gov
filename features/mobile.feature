Feature: Mobile Search
  In order to get government-related information on my mobile device
  As a mobile device user
  I want to be able to search with a streamlined interface

  Scenario: Visiting the home page from a mobile device
    Given I am using a mobile device
    Given I am on the homepagess
    Then I should see "Full Site"

  Scenario: A search on the mobile home page
    Given I am using a mobile device
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should see "Results 1-3"
    And I should see "social security"
    And I should see 3 search results
    And I should see "Next Page"

  Scenario: A nonsense search from the mobile home page
    Given I am using a mobile device
    Given I am on the homepage
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search from the home page
    Given I am using a mobile device
    Given I am on the homepage
    When I submit the search form
    Then I should be on the search page
    And I should see "Please enter search term(s)"

  Scenario: A unicode search from the home page
    Given I am using a mobile device
    Given I am on the homepage
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "البيت الأبيض"

  Scenario: A really long search from the home page
    Given I am using a mobile device
    Given I am on the homepage
    When I fill in "query" with a 10000 character string
    And I submit the search form
    Then I should see "That is too long a word. Try using a shorter word."

