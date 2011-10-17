Feature: Forms Home Page and Search
  In order to find government related forms
  a U.S. Citizen
  wants to search for forms

  Scenario: Forms search
    Given I am on the homepage
    When I follow "Forms" in the search navigation
    Then I should be on the forms home page
    And I should not see "ROBOTS" meta tag
    And I should see "Connect with USASearch" in the connect section
    And I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Mobile" with url for "http://m.usa.gov" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    And I should see a link to "Share" with url for "http://www.addthis.com/bookmark.php" in the connect section
    When I fill in "query" with "White House"
    And I press "Search Forms"
    Then I should be on the forms search page
    And I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see "Forms" in the selected vertical navigation
    And I should see 10 search results
    And I should see "Next"
    And I should see "Connect with USASearch" in the connect section
    And I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Mobile" with url for "http://m.usa.gov" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    And I should see a link to "Share" with url for "http://www.addthis.com/bookmark.php" in the connect section

  Scenario: A nonsense search
    Given I am on the forms home page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I press "Search"
    Then I should see "Oops! We can't find results for your search: kjdfgkljdhfgkldjshfglkjdsfhg"
    And I should see a link to "Government Forms" with url for "http://www.usa.gov/Topics/Reference_Shelf/forms.shtml" in the no results section
    And I should see a link to "Contact USA.gov" with url for "http://www.usa.gov/Contact_Us.shtml" in the no results section
    And I should see "Source:" in the no results section

  Scenario: Doing a blank search from the forms home page
    Given I am on the forms home page
    When I submit the search form
    Then I should be on the forms home page

  Scenario: Doing a blank search from the forms SERP
    Given I am on the forms search page
    When I submit the search form
    Then I should be on the forms home page

  Scenario: A unicode search
    Given I am on the forms home page
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "البيت الأبيض"

  Scenario: No Spanish or Advanced links
    Given I am on the forms home page
    Then I should not see "Advanced Search"
    And I should not see "Busque en español"

    Given I am on the forms search page
    Then I should not see "Advanced Search"
    And I should not see "Busque en español"

  Scenario: Switching to web search
    Given I am on the forms home page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the forms search page
    When I follow "Web"
    Then I should be on the search page
    And I should see at least 8 search results

  Scenario: Switching to image search
    Given I am on the forms home page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the forms search page
    When I follow "Images" in the search navigation
    Then I should be on the image search page
    And I should see 30 image results

  Scenario: Switching to Forms search from web or image search
    Given I am on the homepage
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the search page
    When I follow "Forms" in the search navigation
    Then I should be on the forms search page
    And I should see 10 search results

    When I follow "Images" in the search navigation
    Then I should be on the image search page
    When I follow "Forms" in the search navigation
    Then I should be on the forms search page
    And I should see 10 search results

  Scenario: Viewing Top Forms on Forms Landing Page
    Given the following Top Forms exist:
    | name            | url                 | column_number | sort_order  |
    | Column 1        |                     | 1             | 1           |
    | Link 1.1        | http://link11.com   | 1             | 10          |
    | Link 1.2        | http://link12.com   | 1             | 20          |
    | Column 3        |                     | 3             | 1           |
    And I am on the forms home page
    Then I should see "Column 1" within "#top-forms-column-1"
    And I should see "Link 1.1" within "#top-forms-column-1"
    And I should see "Link 1.2" within "#top-forms-column-1"
    And I should see "Column 3" within "#top-forms-column-3"

  Scenario: A forms search that matches a spotlight
    Given the following active Spotlights exist:
    | title             | keywords  |  html                                       |
    | Automobile Tires  | tires     | <div id="spotlight">Automobile Tires</div>  |
    And I am on the forms home page
    When I fill in "query" with "tires"
    And I press "Search"
    Then I should be on the forms search page
    And in "spotlight" I should not see "Automobile Tires"