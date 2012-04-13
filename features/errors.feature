Feature: Errors
  As a site visitor
  I want to see improved 404 page
  So that I can find the information I need

  Scenario: Going to the 404 page
    When I go to the 404 page
    Then I should see the browser page titled "Oops! We can't find the file - USA.gov"
    And I should see "Oops! We can't find the file."
    And I should see "What should you do?"
    When I fill in "query" with "USA"
    And I press "Search"
    Then I should see "Results 1-10"

  Scenario: Going to the Spanish 404 page
    When I go to the Spanish 404 page
    Then I should see the browser page titled "La página que busca no está disponible - Gobierno.USA.gov"
    And I should see "La página que busca no está disponible."
    And I should see "¿Qué puede hacer?"
    When I fill in "query" with "USA"
    And I press "Buscar"
    Then I should see "Resultados 1-10"

  Scenario: Going to an affiliate 404 page in English
     Given the following Affiliates exist:
       | display_name | name    | contact_email | contact_name | header      | footer      | staged_header | staged_footer | uses_managed_header_footer |
       | aff site     | aff.gov | aff@bar.gov   | John Bar     | Live header | Live footer | Staged header | Staged footer | false                      |
    When I go to the aff.gov's 404 page
    Then I should see the browser page titled "Oops! We can't find the file - aff site"
    And I should see "Live header"
    And I should see "Oops! We can't find the file."
    And I should see "What should you do?"
    And I should see "Please describe what you are looking for:"
    And I should see "Live footer"
    When I fill in "query" with "USA"
    And I press "Search"
    Then I should see "Results 1-10"

    When I go to the aff.gov's staged 404 page
    Then I should see the browser page titled "Oops! We can't find the file - aff site"
    And I should see "Staged header"
    And I should see "Oops! We can't find the file."
    And I should see "What should you do?"
    And I should see "Please describe what you are looking for:"
    And I should see "Staged footer"
    When I fill in "query" with "USA"
    And I press "Search"
    Then I should see "Results 1-10"

  Scenario: Going to an affiliate 404 page in Spanish
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | header      | footer      | staged_header | staged_footer | uses_managed_header_footer | locale |
      | aff site     | es.aff.gov | aff@bar.gov   | John Bar     | Live header | Live footer | Staged header | Staged footer | false                      | es     |
    When I go to the es.aff.gov's 404 page
    Then I should see the browser page titled "La página que busca no está disponible - aff site"
    And I should see "Live header"
    And I should see "La página que busca no está disponible."
    And I should see "¿Qué puede hacer?"
    And I should see "Por favor describa la información que busca:"
    And I should see "Live footer"
    When I fill in "query" with "USA"
    And I press "Buscar"
    Then I should see "Resultados 1-10"

    When I go to the es.aff.gov's staged 404 page
    Then I should see the browser page titled "La página que busca no está disponible - aff site"
    And I should see "Staged header"
    And I should see "La página que busca no está disponible."
    And I should see "¿Qué puede hacer?"
    And I should see "Por favor describa la información que busca:"
    And I should see "Staged footer"
    When I fill in "query" with "USA"
    And I press "Buscar"
    Then I should see "Resultados 1-10"

  Scenario: Going to the 404 page using mobile device
    Given I am using a mobile device
    When I go to the 404 page
    Then I should see the browser page titled "The page you were looking for doesn't exist (404)"
    And I should see "The page you were looking for doesn't exist."

