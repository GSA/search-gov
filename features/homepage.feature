Feature: Homepage
  In order to get government-related information
  As a site visitor
  I want to be able to search for information

  Scenario: Visiting the home page
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | header         | search_results_page_title           |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | USA.gov Header | {Query} - {SiteName} Search Results |
    When I am on the homepage
    Then I should not see "ROBOTS" meta tag
    And I should see a link to "USA.gov" with url for "http://www.usa.gov/index.shtml" in the homepage header
    And I should see a link to "FAQs" with url for "http://answers.usa.gov/"
    And I should see a link to "E-mail USA.gov" with url for "http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/ask.php"
    And I should see a link to "Chat" with url for "http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/chat.php"
    And I should see a link to "Publications" with url for "http://publications.usa.gov/"
    And I should see "GOVERNMENT" in the search navigation
    And I should see a link to "Change Text Size" with url for "http://www.usa.gov/About/Change_Text.shtml"
    And I should see "Connect with USASearch" in the connect section
    And I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Mobile" with url for "http://m.usa.gov" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    And I should see a link to "Share" with url for "http://www.addthis.com/bookmark.php" in the connect section
    And I should see a link to "USA.gov" with url for "http://www.usa.gov/index.shtml" in the homepage footer
    And I should see a link to "Website Policies" with url for "http://www.usa.gov/About/Important_Notices.shtml"
    And I should see a link to "Privacy" with url for "http://www.usa.gov/About/Privacy_Security.shtml"
    And I should see "USASearch Program"
    And I should see "Affiliate Program"
    And I should see "APIs and Web Services"
    And I should see "Search.USA.gov" in the homepage tagline

  Scenario: A typical popular search from the home page
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | header         | search_results_page_title           |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | USA.gov Header | {Query} - {SiteName} Search Results |
    When I am on the homepage
    And I fill in "query" with "president"
    And I submit the search form
    Then I should see the browser page titled "president - USA.gov Search Results"
    And I should see "USA.gov Header"
    And I should not see "<strong>president</strong>"

  Scenario: Entering a blank advanced search
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | header         | search_results_page_title           |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | USA.gov Header | {Query} - {SiteName} Search Results |
    When I am on the advanced search page
    And I press "Search"
    Then I should be on the search page
    And I should see "Please enter search term(s)"

  Scenario: A unicode search from the home page
    Given I am on the homepage
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "البيت الأبيض"

  Scenario: Visiting the homepage as a Spanish speaker
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | contact_name | header                  | search_results_page_title                      | locale |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John Bar     | Gobierno.USA.gov Header | {Query} - {SiteName} resultados de la búsqueda | es     |
    When I am on the Spanish homepage
    Then I should see a link to "GobiernoUSA.gov" with url for "http://www.usa.gov/gobiernousa/index.shtml" in the homepage header
    And I should see a link to "Respuestas" with url for "http://respuestas.gobiernousa.gov/"
    And I should see a link to "Contactos" with url for "http://www.usa.gov/gobiernousa/Contactenos.shtml"
    And I should see "GOBIERNO" in the search navigation
    And I should see a link to "Cambiar el tamaño del texto" with url for "http://www.usa.gov/gobiernousa/Tamano_Texto.shtml"
    And I should not see "Connect with USASearch"
    And I should see a link to "GobiernoUSA.gov" with url for "http://www.usa.gov/gobiernousa/index.shtml" in the homepage footer
    And I should see a link to "Políticas del sitio" with url for "http://www.usa.gov/gobiernousa/Politicas_Sitio.shtml"
    And I should see a link to "Privacidad" with url for "http://www.usa.gov/gobiernousa/Privacidad_Seguridad.shtml"
    And I should see "Móvil"
    And I should see "Buscador.USA.gov" in the homepage tagline

  Scenario: a typical search from the Spanish homepage
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | contact_name | header                  | search_results_page_title                      | locale |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John Bar     | Gobierno.USA.gov Header | {Query} - {SiteName} resultados de la búsqueda | es     |
    When I am on the Spanish homepage
    Then I should see the browser page titled "Buscador.USA.gov: el buscador oficial del Gobierno de los Estados Unidos en español"
    When I fill in "query" with "president"
    And I press "Buscar"
    Then I should see the browser page titled "president - GobiernoUSA.gov resultados de la búsqueda"
    And I should not see "<strong>President</strong>"

  Scenario: Clicking on the red Buscador.USA.gov button
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | contact_name | header                  | search_results_page_title                      | locale |
      | USA.gov         | usagov      | aff@bar.gov   | John Bar     | USA.gov Header          | {Query} - {SiteName} Search Results            | en     |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John Bar     | Gobierno.USA.gov Header | {Query} - {SiteName} resultados de la búsqueda | es     |
    When I am on the homepage
    And I follow "Buscador.USA.gov" in the search navigation
    Then I should see the browser page titled "Buscador.USA.gov: el buscador oficial del Gobierno de los Estados Unidos en español"

  Scenario: Clicking on the red Search.USA.gov button
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | contact_name | header                  | search_results_page_title                      | locale |
      | USA.gov         | usagov      | aff@bar.gov   | John Bar     | USA.gov Header          | {Query} - {SiteName} Search Results            | en     |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John Bar     | Gobierno.USA.gov Header | {Query} - {SiteName} resultados de la búsqueda | es     |
    When I am on the Spanish homepage
    And I follow "Search.USA.gov" in the search navigation
    Then I should see the browser page titled "Search.USA.gov: The U.S. Government's Official Search Engine"

  Scenario: Clicking on Advanced Search on the homepage
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | header         | search_results_page_title           |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | USA.gov Header | {Query} - {SiteName} Search Results |
    When I am on the homepage
    And I follow "Advanced Search"
    Then I should see the browser page titled "Advanced Search"
    And I should see "Use the options on this page to create a very specific search."

  Scenario: Visiting ABOUT USASearch links
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | header         | search_results_page_title           |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | USA.gov Header | {Query} - {SiteName} Search Results |
    When I am on the homepage
    And I follow "USASearch Program" in the homepage about section
    Then I should be on the program welcome page

    When I am on the homepage
    And I follow "Affiliate Program" in the homepage about section
    Then I should be on the affiliates page

    When I am on the homepage
    And I follow "APIs and Web Services" in the homepage about section
    Then I should be on the api page

    When I am on the homepage
    And I follow "Search.USA.gov" in the homepage about section
    Then I should be on the searchusagov page

  Scenario: Visiting other verticals from the homepage
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | header         | search_results_page_title           |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | USA.gov Header | {Query} - {SiteName} Search Results |
    When I am on the homepage
    And I follow "Images" in the search navigation
    Then I should be on the images page
