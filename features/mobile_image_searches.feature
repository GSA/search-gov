Feature: Image search using mobile template
  In order to get government-related images
  As a site visitor
  I want to search for images

  Background:
    Given I am using a TabletPC device

  Scenario: English Image search with matching Flickr photos
    Given the following Affiliates exist:
      | display_name      | name     | contact_email | contact_name | is_image_search_navigable | is_bing_image_search_enabled |
      | USA.gov           | usagov   | aff@bar.gov   | John Bar     | true                      | false                        |
      | USA.gov with Bing | usagovcr | aff@bar.gov   | John Bar     | true                      | true                         |
    And there are 5 flickr photos for "usagov" with title prefix "sunset"
    And there are 20 flickr photos for "usagovcr" with title prefix "sunset sunrise"

    When I am on usagov's search page
    And I fill in "Enter your search term" with "sunset"
    And I press "Search"
    And I follow "Images" within the SERP navigation
    Then I should see exactly "5" image search results
    And I should see "Powered by DIGITALGOV Search"
    And I should not see "Try your search again"

    When I am on usagovcr's search page
    And I fill in "Enter your search term" with "sunset"
    And I press "Search"
    And I follow "Images" within the SERP navigation
    Then I should see exactly "20" image search results
    And I should see "Powered by DIGITALGOV Search"
    When I follow "Try your search again"

    Then I should see exactly "20" image search results
    And I should see "Powered by Bing"
    When I follow "Next"
    Then I should see exactly "20" image search results
    And I should see "Powered by Bing"

    When I fill in "Enter your search term" with "sunrise"
    And I press "Search"
    Then I should see exactly "20" image search results
    And I should see "Powered by DIGITALGOV Search"

  Scenario: English Image search without matching Flickr photos
    Given the following Affiliates exist:
      | display_name      | name     | contact_email | contact_name | is_image_search_navigable | is_bing_image_search_enabled |
      | USA.gov           | usagov   | aff@bar.gov   | John Bar     | true                      | false                        |
      | USA.gov with Bing | usagovcr | aff@bar.gov   | John Bar     | true                      | true                         |
    And there are 5 flickr photos for "usagov" with title prefix "sunset"

    When I am on usagov's search page
    And I fill in "Enter your search term" with "gov"
    And I press "Search"
    And I follow "Images" within the SERP navigation
    Then I should see "no results found"

    When I am on usagovcr's search page
    And I fill in "Enter your search term" with "gov"
    And I press "Search"
    And I follow "Images" within the SERP navigation
    Then I should see exactly "20" image search results
    And I should see "Powered by Bing"

  Scenario: Spanish image search with matching Flickr photos
    Given the following Affiliates exist:
      | display_name              | name          | contact_email | contact_name | locale | is_image_search_navigable | is_bing_image_search_enabled |
      | GobiernoUSA.gov           | gobiernousa   | aff@bar.gov   | John Bar     | es     | true                      | false                        |
      | GobiernoUSA.gov with Bing | gobiernousacr | aff@bar.gov   | John Bar     | es     | true                      | true                         |
    And there are 5 flickr photos for "gobiernousa" with title prefix "puesta del sol"
    And there are 5 flickr photos for "gobiernousacr" with title prefix "puesta del sol"

    When I am on gobiernousa's search page
    And I fill in "Ingrese su búsqueda" with "del sol"
    And I press "Buscar"
    And I follow "Imágenes" within the SERP navigation
    Then I should see exactly "5" image search results
    And I should see "Generado por DIGITALGOV Search"
    And I should not see "Intente esta búsqueda otra vez"

    When I am on gobiernousacr's search page
    And I fill in "Ingrese su búsqueda" with "del sol"
    And I press "Buscar"
    And I follow "Imágenes" within the SERP navigation
    Then I should see exactly "5" image search results
    And I should see "Generado por DIGITALGOV Search"

    When I follow "Intente esta búsqueda otra vez"
    Then I should see exactly "20" image search results
    And I should see "Generado por Bing"
    When I follow "Siguiente"
    Then I should see exactly "20" image search results
    And I should see "Generado por Bing"

    And I fill in "Ingrese su búsqueda" with "puesta"
    And I press "Buscar"
    Then I should see exactly "5" image search results
    And I should see "Generado por DIGITALGOV Search"

  Scenario: English Image search on a legacy site
    Given the following legacy Affiliates exist:
      | display_name      | name     | contact_email | contact_name | is_image_search_navigable |
      | USA.gov           | usagov   | aff@bar.gov   | John Bar     | true                      |
    When I am on usagov's search page
    And I fill in "Enter your search term" with "sunset"
    And I press "Search"
    And I follow "Images" within the SERP navigation
    Then I should see exactly "20" image search results
    And I should see "Powered by Bing"
