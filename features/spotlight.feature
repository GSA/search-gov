Feature: Spotlight
  In order to provide emergency/time-sensitive content above search results triggered by keywords
  As an Admin
  I want to create/update/edit/delete search spotlights

  Scenario: Managing a spotlight as a logged in administrator
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following active Spotlights exist:
    | title                  | keywords                                         |  html                                          |
    | White House            | casa blanca, contact mr obama, white house tour  | <div id="spotlight">White House Content</div>  |
    | National Park Service  | annual park pass, federal park, fee free weekend | <div id="spotlight">NPS Content</div>          |
    When I am on the spotlights admin homepage
    Then I should see "White House"
    And I should see "National Park Service"
    And I should see "casa blanca"
    And I should see "annual park pass"

  Scenario: Spotlight results from a search on the home page
    Given I am on the homepage
    And the following active Spotlights exist:
    | title                  | keywords                                         |  html                                          |
    | White House            | casa blanca, contact mr obama, white house tour  | <div id="spotlight">White House Content</div>  |
    | National Park Service  | annual park pass, federal park, fee free weekend | <div id="spotlight">NPS Content</div>          |
    When I fill in "query" with "tours of the white house"
    And I submit the search form
    Then I should be on the search page
    And in "spotlight" I should see "White House Content"
    
  Scenario: Spotlight results from an affiliate search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following active Spotlights exist for "aff.gov":
      | title                  | keywords                                         |  html                                          |
      | White House            | casa blanca, contact mr obama, white house tour  | <div id="spotlight">White House Content</div>  |
      | National Park Service  | annual park pass, federal park, fee free weekend | <div id="spotlight">NPS Content</div>          |
    When I go to aff.gov's search page
    And I fill in "query" with "tours of the white house"
    And I press "Search"
    Then in "spotlight" I should see "White House Content"