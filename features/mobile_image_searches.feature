Feature: Image search using mobile template
  In order to get government-related images
  As a site visitor
  I want to search for images

  Background:
    Given I am using a TabletPC device

  Scenario: English Image search
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | is_image_search_navigable |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | true                      |
    Given the following FlickrPhotos exist:
      | affiliate_name | title    | url_q                                   |
      | usagov         | sunset 1 | http://farm9.staticflickr.com/1/1_q.jpg |
      | usagov         | sunset 2 | http://farm9.staticflickr.com/2/2_q.jpg |
    When I am on usagov's search page
    And I fill in "Enter your search term" with "sunset"
    And I press "Search"
    And I follow "Images" within the SERP navigation
    Then I should see exactly "2" image search results
    And I should see "Powered by DIGITALGOV Search"

  Scenario: Spanish image search
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | contact_name | locale | is_image_search_navigable |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John Bar     | es     | true                      |
    Given the following FlickrPhotos exist:
      | affiliate_name | title          | url_q                                   |
      | gobiernousa    | puesta del sol | http://farm9.staticflickr.com/1/1_q.jpg |
      | gobiernousa    | puesta del sol | http://farm9.staticflickr.com/2/2_q.jpg |
    When I am on gobiernousa's search page
    And I fill in "Ingrese su búsqueda" with "del sol"
    And I press "Buscar"
    And I follow "Imágenes" within the SERP navigation
    Then I should see exactly "2" image search results
    And I should see "Generado por DIGITALGOV Search"
