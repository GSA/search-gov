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
    And I should see "Next"

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
    Then I should see "البيت الأبيض"

  Scenario: A really long search from the home page
    Given I am on the homepage
    When I fill in "query" with a 10000 character string
    And I submit the search form
    Then I should see "That is too long a word. Try using a shorter word."

  Scenario: Visiting the homepage as a Spanish speaker
    Given I am on the homepage
    And I follow "Busque en español"
    Then I should see "Contáctenos"
    And I should see "Sugiera un enlace"

  Scenario: Switching to image search
    Given I am on the search page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the search page
    When I follow "Images" within "#search_form"
    Then I should be on the image search page
    And I should see 30 image results

  Scenario: Clicking on Advanced Search on the homepage
    Given I am on the homepage
    And I follow "Advanced Search"
    Then I should see "Use the options on this page to create a very specific search."

  Scenario: Clicking on 'Need Larger Text'
    Given I am on the homepage
    And I follow "Need Larger Text?"
    Then I should see "Change Text Size"
    And I should see "En Español"

  Scenario: Visiting Homepage as a Spanish speaker and needing larger text
    Given I am on the homepage
    And I follow "Busque en español"
    And I follow "¿Necesita letra grande?"
    Then I should see "Cómo cambiar el tamaño del texto"
    And I should see "In English"    
