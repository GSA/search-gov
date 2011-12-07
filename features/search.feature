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
    And I should see "Web" in the selected vertical navigation
    And I should not see "<strong>President</strong>"

  Scenario: Visiting Spanish search homepage
    When I am on the homepage
    And I follow "Busque en español"
    Then I should see the browser page titled "Buscador.USA.gov: el buscador oficial del Gobierno de los Estados Unidos en español"
    When I fill in "query" with "president"
    And I press "Buscar"
    Then I should see the browser page titled "president - Buscador.USA.gov"
    And I should see "Web" in the selected vertical navigation
    And I should not see "<strong>President</strong>"

  Scenario: Viewing related English FAQs
    Given the following FAQs exist:
    | url                   | question                                      | answer        | ranking | locale  |
    | http://localhost:3000 | Who is the president of the United States?    | Barack Obama  | 1       | en      |
    | http://localhost:3000 | Who is the president of the Estados Unidos?   | Barack Obama  | 1       | es      |
    And I am on the homepage
    And I fill in "query" with "president"
    And I press "Search"
    Then I should be on the search page
    And I should see "Questions & Answers for president by USA.gov" after the 5th search result
    And I should see "Who is the president of the United States?" after the 5th search result
    And I should not see "Who is the president of the Estados Unidos?"
    When I follow "2" in the pagination
    Then I should not see "Questions & Answers for president by USA.gov"

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
    And I should see "Respuestas para president de GobiernoUSA.gov" after the 5th search result
    And I should see "Who is the president of the Estados Unidos?" after the 5th search result
    And I should not see "Who is the president of the United States?"
    When I follow "2" in the pagination
    Then I should not see "Respuestas para president de GobiernoUSA.gov"

  Scenario: Related Topics on English SERPs
    Given the following Calais Related Searches exist:
    | term    | related_terms             | locale |
    | obama   | Some Unique Obama Term    | en     |
    | el paso | el presidente mas guapo   | es     |
    And the following SAYT Suggestions exist:
    | phrase                 |
    | Some Unique Obama Term |
    | el paso term           |
    And I am on the homepage
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should be on the search page
    And I should see "Related Searches for obama by USA.gov" in the search results section
    And I should see "some unique obama term"
    When I fill in "query" with "el paso"
    And I press "Search"
    Then I should not see "el presidente mas guapo"

  Scenario: Related Topics on Spanish SERPs
    Given the following Calais Related Searches exist:
    | term  | related_terms                   | locale |
    | hello | some unique related term        | en     |
    | obama | el presidente obama mas guapo   | es     |
    And the following SAYT Suggestions exist:
    | phrase                        |
    | el presidente obama mas guapo |
    | el paso term                  |
    And I am on the homepage
    And I follow "Busque en español"
    And I fill in "query" with "obama"
    And I press "Buscar"
    Then I should be on the search page
    And I should see "Búsquedas relacionadas a obama de GobiernoUSA.gov" in the search results section
    And I should see "el presidente obama mas guapo"
    When I fill in "query" with "hello"
    And I press "Buscar"
    And I should not see "some unique related term"

  Scenario: Site visitor sees both boosted result and featured collection for a given search
    Given the following Boosted Content entries exist:
      | title              | url                    | description                          |
      | Our Emergency Page | http://www.aff.gov/911 | Updated information on the emergency |
      | FAQ Emergency Page | http://www.aff.gov/faq | More information on the emergency    |
    Given the following featured collections exist:
      | title                    | locale | status |
      | Emergency & Safety Pages | en     | active |
    And the following featured collection links exist for featured collection titled "Emergency & Safety Pages":
      | title          | url                               |
      | Emergency Info | http://www.agency.org/emergency/1 |
      | Safety Info    | http://www.agency.org/safety/1    |
    And I am on the homepage
    And I fill in "query" with "emergency"
    And I press "Search"
    Then I should see "Our Emergency Page" in the boosted contents section
    And I should see "FAQ Emergency Page" in the boosted contents section
    And I should see "Emergency & Safety Pages" in the featured collections section

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

  Scenario: Spanish site visitor sees relevant boosted results for given search
    Given the following Boosted Content entries exist:
      | title                                  | url                    | description                          | keywords         | locale |
      | Nuestra página de Emergencia           | http://www.aff.gov/911 | Updated information on the emergency | unrelated, terms | es     |
      | Preguntas frecuentes emergencia página | http://www.aff.gov/faq | More information on the emergency    |                  | es     |
      | Our Tourism Page                       | http://www.aff.gov/tou | Tourism information                  |                  | en     |
    And the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title                             | url                    | description                        | keywords | locale |
      | la página de prueba de Emergencia | http://www.bar.gov/911 | This should not show up in results |          | es     |
    When I go to the Spanish homepage
    And I fill in "query" with "emergencia"
    And I press "Buscar"
    Then I should see "Recomendación de GobiernoUSA.gov"
    And I should see "Nuestra página de Emergencia" within "#boosted"
    And I should see "Preguntas frecuentes emergencia página" within "#boosted"
    And I should not see "Our Tourism Page" within "#boosted"
    And I should not see "la página de prueba de Emergencia" within "#boosted"

    When I fill in "query" with "unrelated"
    And I press "Buscar"
    Then I should see "Nuestra página de Emergencia" within "#boosted"

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
      | Our Emergency Page | http://www.aff.gov/mysuperduperawesomelongurl/911  | Updated information on the emergency | en      |
    And I am on the homepage
    And I fill in "query" with "emergency"
    And I press "Search"
    Then I should see "www.aff.gov/.../911"

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

  Scenario: Searchers see agency popular pages in English
    Given the following Agency entries exist:
      | name | domain  |
      | SSA  | ssa.gov |
    And the following Agency Urls exist:
      | name | locale | url                         |
      | SSA  | en     | http://www.ssa.gov/         |
      | SSA  | es     | http://www.ssa.gov/espanol/ |
    And the following Agency Popular Urls exist:
      | name | locale | rank | title                                 | url                                                |
      | SSA  | en     | 20   | Get or replace a Social Security card | http://www.ssa.gov/ssnumber/                       |
      | SSA  | en     | 10   | Apply online for retirement benefits  | http://www.ssa.gov/planners/about.htm              |
      | SSA  | es     | 20   | Solicite beneficios de jubilación     | http://www.ssa.gov/espanol/plan/sobreelplan.htm    |
      | SSA  | es     | 10   | Solicite beneficios de incapacidad    | http://www.ssa.gov/espanol/soliciteporincapacidad/ |
    When I am on the homepage
    And I fill in "query" with "ssa"
    And I press "Search"
    Then I should see a link to "Get or replace a Social Security card" with url for "http://www.ssa.gov/ssnumber/" on the popular pages list
    And I should see a link to "Apply online for retirement benefits" with url for "http://www.ssa.gov/planners/about.htm" on the popular pages list
    And I should not see a link to "Solicite beneficios de jubilación" with url for "http://www.ssa.gov/espanol/plan/sobreelplan.htm" on the popular pages list
    And I should not see a link to "Solicite beneficios de incapacidad" with url for "http://www.ssa.gov/espanol/soliciteporincapacidad/" on the popular pages list

  Scenario: Searchers see agency popular pages in Spanish
    Given the following Agency entries exist:
      | name | domain  |
      | SSA  | ssa.gov |
    And the following Agency Urls exist:
      | name | locale | url                         |
      | SSA  | en     | http://www.ssa.gov/         |
      | SSA  | es     | http://www.ssa.gov/espanol/ |
    And the following Agency Popular Urls exist:
      | name | locale | rank | title                                 | url                                                |
      | SSA  | en     | 20   | Get or replace a Social Security card | http://www.ssa.gov/ssnumber/                       |
      | SSA  | en     | 10   | Apply online for retirement benefits  | http://www.ssa.gov/planners/about.htm              |
      | SSA  | es     | 20   | Solicite beneficios de jubilación     | http://www.ssa.gov/espanol/plan/sobreelplan.htm    |
      | SSA  | es     | 10   | Solicite beneficios de incapacidad    | http://www.ssa.gov/espanol/soliciteporincapacidad/ |
    When I am on the Spanish homepage
    And I fill in "query" with "ssa"
    And I press "Buscar"
    Then I should see a link to "Solicite beneficios de jubilación" with url for "http://www.ssa.gov/espanol/plan/sobreelplan.htm" on the popular pages list
    And I should see a link to "Solicite beneficios de incapacidad" with url for "http://www.ssa.gov/espanol/soliciteporincapacidad/" on the popular pages list
    And I should not see a link to "Get or replace a Social Security card" with url for "http://www.ssa.gov/ssnumber/" on the popular pages list
    And I should not see a link to "Apply online for retirement benefits" with url for "http://www.ssa.gov/planners/about.htm" on the popular pages list

  Scenario: Searching for a Spanish word without diacritics
    Given the following Boosted Content entries exist:
      | title              | url                                                            | description                               |
      | Día de los Muertos | http://www.latino.si.edu/education/LVMDayoftheDeadFestival.htm | The Smithsonian Latino Center presents... |
    And I am on the homepage
    And I fill in "query" with "dia"
    And I press "Search"
    Then I should see "Día de los Muertos"
    And I should see "The Smithsonian Latino Center presents"

    When I am on the homepage
    And I fill in "query" with "Día"
    And I press "Search"
    Then I should see "Día de los Muertos"
    And I should see "The Smithsonian Latino Center presents"
    
  Scenario: When search results have results that are from excluded domains
    Given the following Excluded Domains exist:
    | domain          |
    | windstream.net  |
    And I am on the homepage
    And I fill in "query" with "windstream"
    And I press "Search"
    Then I should not see "windstream.net"
