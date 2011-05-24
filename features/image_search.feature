Feature: Image search
  In order to get government-related images
  As a site visitor
  I want to search for images

  Scenario: Image search
    Given I am on the homepage
    When I follow "Images" in the search navigation
    Then I should be on the images page
    And I should see the browser page titled "Search.USA.gov Images"
    And I should not see "ROBOTS" meta tag
    And I should see "Busque en español"
    And I should not see "Advanced Search"
    When I follow "USASearch Images Home"
    Then I should be on the images page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the image search page
    And I should see the browser page titled "White House - Search.USA.gov Images"
    And I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see 30 image results
    And I should see "Next"
    When I follow "USASearch Images Home"
    Then I should be on the images page

  Scenario: Visiting Spanish image search homepage
    Given I am on the homepage
    And I follow "Busque en español"
    And I follow "Imágenes" in the search navigation
    Then I should be on the images page
    And I should see the browser page titled "el buscador oficial en español del Gobierno de los Estados Unidos"
    When I follow "USASearch Images Home"
    Then I should be on the images page
    When I fill in "query" with "White House"
    And I press "Buscar"
    Then I should be on the image search page
    And I should see the browser page titled "White House - el buscador oficial en español del Gobierno de los Estados Unidos"
    And I should see 30 image results
    And I should see "Siguiente"
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
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

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
    And I should see 10 search results

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
