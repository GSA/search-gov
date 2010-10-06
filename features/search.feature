Feature: Search
  In order to get government-related search results
  As a site visitor
  I want to search for web pages

  Scenario: Viewing related English FAQs
    Given the following FAQs exist:
    | url                   | question                                      | answer        | ranking | locale  |
    | http://localhost:3000 | Who is the president of the United States?    | Barack Obama  | 1       | en      |
    | http://localhost:3000 | Who is the president of the Estados Unidos?   | Barack Obama  | 1       | es      |
    And I am on the homepage
    And I fill in "query" with "president"
    And I press "Search"
    Then I should be on the search page
    And I should see "Related Questions and Answers"
    And I should see "Who is the president of the United States?"
    And I should not see "Who is the president of the Estados Unidos?"

  Scenario: Viewing related Spanish FAQs
    Given the following FAQs exist:
    | url                   | question                                      | answer        | ranking | locale  |
    | http://localhost:3000 | Who is the president of the United States?    | Barack Obama  | 1       | en      |
    | http://localhost:3000 | Who is the president of the Estados Unidos?   | Barack Obama  | 1       | es      |
    And I am on the homepage
    And I follow "Busque en español"
    And I fill in "query" with "president"
    And I press "Buscar"
    Then I should be on the search page
    And I should see "Respuestas relacionadas"
    And I should not see "Who is the president of the United States?"
    And I should see "Who is the president of the Estados Unidos?"

  Scenario: Related Topics on English SERPs
    Given the following Calais Related Searches exist:
    | term    | related_terms             | locale |
    | obama   | Some Unique Related Term  | en     |
    | el paso | el presidente mas guapo   | es     |
    And I am on the homepage
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should be on the search page
    And I should see "Related Topics"
    And I should see "Some Unique Related Term"
    When I fill in "query" with "el paso"
    And I press "Search"
    Then I should not see "El Presidente Mas Guapo"

  Scenario: Related Topics on Spanish SERPs
    Given the following Calais Related Searches exist:
    | term  | related_terms             | locale |
    | hello | Some Unique Related Term  | en     |
    | obama | el presidente mas guapo   | es     |
    And I am on the homepage
    And I follow "Busque en español"
    And I fill in "query" with "obama"
    And I press "Buscar"
    Then I should be on the search page
    And I should see "Temas relacionados"
    And I should see "El Presidente Mas Guapo"
    When I fill in "query" with "hello"
    And I press "Buscar"
    And I should not see "Some Unique Related Term"
