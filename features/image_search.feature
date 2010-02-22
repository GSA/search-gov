Feature: Image search
  In order to get government-related images
  As a site visitor
  I want to search for images
  
  Scenario: Image search
    Given I am on the homepage
    When I follow "Images" within "#search_form"
    Then I should be on the image search page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the image search page
    And I should see 10 image results
    And I should see "Next"

  Scenario: A nonsense search
    Given I am on the image search page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search
    Given I am on the image search page
    When I submit the search form
    Then I should be on the image search page
    And I should see "Please enter search term(s)"

  Scenario: A unicode search
    Given I am on the image search page
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "البيت الأبيض"

  Scenario: A really long search
    Given I am on the image search page
    When I fill in "query" with a 10000 character string
    And I submit the search form
    Then I should see "That is too long a word. Try using a shorter word."

  Scenario: Visiting the image page as a Spanish speaker
    Given I am on the image search page
    And I follow "Busque en español"
    Then I should see "Contáctenos"
    And I should see "Sugiera un enlace"
    
  Scenario: Switching to web search
    Given I am on the image search page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the image search page
    When I follow "Government Web"
    Then I should be on the search page
    And I should see 10 search results