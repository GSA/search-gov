Feature: Forms Home Page and Search
  In order to find government related forms
  a U.S. Citizen
  wants to search for forms
  
  Scenario: Forms search
    Given I am on the homepage
    When I follow "Forms" within "#search_form"
    Then I should be on the forms home page
    And I should see "Forms.gov has moved!"
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the forms search page
    And I should see 10 search results
    And I should see "Next"

  Scenario: A nonsense search
    Given I am on the forms home page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search
    Given I am on the forms home page
    When I submit the search form
    Then I should be on the forms search page
    And I should see "Please enter search term(s)"

  Scenario: A unicode search
    Given I am on the forms home page
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "البيت الأبيض"

  Scenario: A really long search
    Given I am on the forms home page
    When I fill in "query" with a 10000 character string
    And I submit the search form
    Then I should see "That is too long a word. Try using a shorter word."

  Scenario: Searching for forms as a Spanish speaker
    Given I am on the homepage
    And I follow "Busque en español"
    Then I should see "Formas"
    When I follow "Formas"
    Then I should be on the forms home page
    And I should see "Todo el Gobierno"
    And I should see "Forms.gov se ha movido! "
    
    When I fill in "query" with "impuestos"
    And I submit the search form
    Then I should be on the forms search page
    And I should see "Resultados"
    
  Scenario: Visiting the forms search page as a Spanish speaker
    Given I am on the forms home page
    And I follow "Busque en español"
    Then I should see "Contáctenos"
    And I should see "Sugiera un enlace"

  Scenario: Switching to web search
    Given I am on the forms home page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the forms search page
    When I follow "Government Web"
    Then I should be on the search page
    And I should see 10 search results
    
  Scenario: Switching to image search
    Given I am on the forms home page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the forms search page
    When I follow "Images" within "#search_form"
    Then I should be on the image search page
    And I should see 30 image results
  
  Scenario: Switching to Forms search from web or image search
    Given I am on the homepage
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the search page
    When I follow "Forms" within "#search_form"
    Then I should be on the forms search page
    And I should see 10 search results
    
    When I follow "Images" within "#search_form"
    Then I should be on the image search page
    When I follow "Forms" within "#search_form"
    Then I should be on the forms search page
    And I should see 10 search results