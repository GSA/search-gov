Feature: Image search
  In order to get government-related images
  As a site visitor
  I want to search for images

  Scenario: Image search landing page
    Given I am on the homepage
    When I follow "Images" in the search navigation
    Then I should be on the images page
    And I should see the browser page titled "Search.USA.gov Images"
    And I should not see "ROBOTS" meta tag
    And I should see "Busque en español"
    And I should not see "Advanced Search"
    And I should see "Connect with USASearch" in the connect section
    And I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Mobile" with url for "http://m.usa.gov" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    When I follow "USASearch Images Home"
    Then I should be on the images page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the image search page
    And I should see the browser page titled "White House - Search.USA.gov Images"
    And I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see "Images" in the selected vertical navigation
    And I should see 30 image results
    And I should see "Next"
    And I should see "Connect with USASearch" in the connect section
    And I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Mobile" with url for "http://m.usa.gov" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    When I follow "USASearch Images Home"
    Then I should be on the images page

  Scenario: Visiting Spanish image search homepage
    Given I am on the homepage
    And I follow "Busque en español"
    And I follow "Imágenes" in the search navigation
    Then I should be on the images page
    And I should see the browser page titled "Buscador.USA.gov Imágenes"
    And I should not see "Connect with USASearch"
    When I follow "USASearch Images Home"
    Then I should be on the images page
    When I fill in "query" with "White House"
    And I press "Buscar"
    Then I should be on the image search page
    And I should see the browser page titled "White House - Buscador.USA.gov Imágenes"
    And I should see "Imágenes" in the selected vertical navigation
    And I should see 30 image results
    And I should see "Siguiente"
    And I should not see "Connect with USASearch"
    When I follow "USASearch Images Home"
    Then I should be on the images page

  Scenario: Visiting English image search homepage from the Spanish image search homepage
    Given I am on the homepage
    When I follow "Busque en español"
    Then I should be on the homepage
    When I follow "Imágenes" in the search navigation
    Then I should be on the images page
    When I follow "Search in English"
    Then I should be on the images page
    And I should see "Busque en español"

  Scenario: A nonsense search
    Given I am on the image search page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I press "Search"
    Then I should see "Oops! We can't find results for your search: kjdfgkljdhfgkldjshfglkjdsfhg"
    And I should see a link to "Official Government Flickr Photostreams" with url for "http://www.flickr.com/groups/usagov/" in the no results section
    And I should see a link to "Contact USA.gov" with url for "http://www.usa.gov/Contact_Us.shtml" in the no results section
    And I should see "Source:" in the no results section

  Scenario: A nonsense Spanish search
    Given I am on the homepage
    And I follow "Busque en español"
    And I follow "Imágenes" in the search navigation
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I press "Buscar"
    Then I should see "No hemos podido encontrar resultados que contengan: kjdfgkljdhfgkldjshfglkjdsfhg"
    And I should see a link to "galería oficial de USA.gov en Flickr" with url for "http://www.flickr.com/groups/usagov/" in the no results section
    And I should see a link to "Comuníquese con nosotros" with url for "http://www.usa.gov/gobiernousa/Contactenos.shtml" in the no results section
    And I should see "Fuente:" in the no results section

  Scenario: Doing a blank search
    Given I am on the image search page
    When I submit the search form
    Then I should be on the images page

  Scenario: A unicode search
    Given I am on the image search page
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "البيت الأبيض"

  Scenario: Switching to web search
    Given I am on the image search page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the image search page
    When I follow "Web"
    Then I should be on the search page
    And I should see at least 8 search results

  Scenario: Switching from web search to image search
    Given I am on the homepage
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the search page
    When I follow "Images" in the search navigation
    Then I should be on the image search page
    And I should see 10 search results

  Scenario: Visiting other verticals from the image search homepage
    Given I am on the images page
    When I follow "Web" in the search navigation
    Then I should be on the homepage

    Given I am on the images page
    When I follow "Recalls" in the search navigation
    Then I should be on the recalls page

    Given I am on the images page
    When I follow "Forms" in the search navigation
    Then I should be on the forms page

  Scenario: Site visitor see SERP in English
    When I am on the homepage
    And I follow "Busque en español"
    And I follow "Imágenes" in the search navigation
    And I fill in "query" with "president"
    And I press "Buscar"
    Then I should be on the image search page
    And I should see "president"
    When I follow "Search in English"
    Then I should be on the image search page
    And I should see "Busque en español"
    And I should see "president"

  Scenario: Site visitor see SERP in Spanish
    When I am on the images page
    And I fill in "query" with "president"
    And I press "Search"
    Then I should be on the image search page
    And I should see "president"
    When I follow "Busque en español"
    Then I should be on the image search page
    And I should see "Search in English"
    And I should see "president"
