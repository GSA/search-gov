Feature: Search
  In order to get government-related search results
  As a site visitor
  I want to search for web pages

  Scenario: Visiting English search homepage
    When I am on the homepage
    Then I should see the browser page titled "Search.USA.gov: The U.S. Government's Official Search Engine"
    When I fill in "query" with "president"
    And I press "Search"
    Then I should see the browser page titled "president - Search.USA.gov"
    And I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag

  Scenario: Visiting Spanish search homepage
    When I am on the homepage
    And I follow "Busque en español"
    Then I should see the browser page titled "el buscador oficial en español del Gobierno de los Estados Unidos"
    When I fill in "query" with "president"
    And I press "Buscar"
    Then I should see the browser page titled "president - el buscador oficial en español del Gobierno de los Estados Unidos"

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
    
  Scenario: Site visitor sees relevant boosted results for given search  
    Given the following Boosted Content entries exist:
      | title               | url                     | description                               | 
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      | 
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         | 
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title               | url                     | description                               |
      | Bar Emergency Page  | http://www.bar.gov/911  | This should not show up in results        |
      | Pelosi misspelling  | http://www.bar.gov/pel  | Synonyms file test works                  |
      | all about agencies  | http://www.bar.gov/pe2  | Stemming works                            |
    And I am on the homepage
    And I fill in "query" with "emergency"
    And I press "Search"
    Then I should be on the search page
    And I should see "Our Emergency Page" 
    And I should see "FAQ Emergency Page" 
    And I should not see "Our Tourism Page" 
    And I should not see "Bar Emergency Page"
    
  Scenario: Site visitor sees full boosted content
    Given the following Boosted Content entries exist:
    | title                               | url             | description                               | 
    | FBI Releases 'Flying Saucers' Memo  | http://fbi.gov  | A newly-released memo, written by agent Guy Hottel, appears to support UFOs and aliens landing in Roswell, New Mexico, in 1947. |
    And I am on the homepage
    And I fill in "query" with "roswell"
    And I press "Search"
    Then I should be on the search page
    And I should see "A newly-released memo, written by agent Guy Hottel, appears to support UFOs and aliens landing in Roswell, New Mexico, in 1947."    
    
  Scenario: Site visitor does not see relevant boosted Content on Buscador
    Given the following Boosted Content entries exist:
      | title                   | url                     | description                               | locale  |
      | Our Emergency Page      | http://www.aff.gov/911  | Updated information on the emergency      | en      |
      | FAQ Emergency Page      | http://www.aff.gov/faq  | More information on the emergency         | en      |
      | Spanish Emergency Page  | http://www.aff.gov/ese  | Spanish Emergency                         | es      |
    And I am on the homepage
    And I follow "Busque en español"
    And I fill in "query" with "emergency"
    And I press "Buscar"
    Then I should be on the search page
    And I should not see "Our Emergency Page"
    And I should not see "FAQ Emergency Page"
    And I should see "Spanish Emergency"

  Scenario: Site visitor sees shorten boosted content URL
    Given the following Boosted Content entries exist:
      | title              | url                                           | description                          | locale  |
      | Our Emergency Page | http://www.aff.gov/mysuperawesomelongurl/911  | Updated information on the emergency | en      |
    And I am on the homepage
    And I fill in "query" with "emergency"
    And I press "Search"
    Then I should see "http://www.aff.gov/.../911"

  Scenario: Site visitor sees SERP with popular images
    Given the following Popular Image Query entries exist:
      | query           |
      | space           |
    And I am on the homepage
    And I fill in "query" with "space"
    And I press "Search"
    Then I should see "Images for space"
    When I follow "Images for space"
    Then I should be on the image search page

  Scenario: Site visitor see SERP in English
    When I am on the homepage
    And I follow "Busque en español"
    And I fill in "query" with "president"
    And I press "Buscar"
    Then I should be on the search page
    And I should see "president"
    When I follow "Search in English"
    Then I should be on the search page
    And I should see "Busque en español"
    And I should see "president"

  Scenario: Site visitor see SERP in Spanish
    When I am on the homepage
    And I fill in "query" with "president"
    And I press "Search"
    Then I should be on the search page
    And I should see "president"
    When I follow "Busque en español"
    Then I should be on the search page
    And I should see "Search in English"
    And I should see "president"

