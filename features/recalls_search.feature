Feature: Recalls search
  In order to get government-related recalls
  As a site visitor
  I want to search for recalls
  
  Scenario: Recalls Search
    Given I am on the recalls search page
    When I fill in "query" with "strollers"
    And I press "Search"
    Then I should be on the recalls search page
    And I should see "strollers"
    
  Scenario: A nonsense search
    Given I am on the recalls search page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search from the recalls home page
    Given I am on the recalls landing page
    When I submit the search form
    Then I should be on the recalls landing page

  Scenario: Doing a blank search from the recalls SERP
    Given I am on the recalls search page
    When I submit the search form
    Then I should be on the recalls landing page

