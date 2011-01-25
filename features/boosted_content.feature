Feature: Boosted Content
  In order to boost specific sites to the top of search results
  And admin
  wants to create boosted Content
  
  Scenario: Create a new Boosted Content entry
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And I am on the boosted contents admin page
    And I follow "Create New"
    And I fill in "Description" with "Test"
    And I fill in "Title" with "Test"
    And I fill in "Url" with "http://www.test.gov"
    And I press "Create"
    When I am on the homepage
    And I fill in "query" with "test"
    And I press "Search"
    Then I should be on the search page
    And I should see "Test" within "#boosted"
    
  Scenario: Update a Boosted Content entry
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Boosted Content entries exist:
    | description | title | url                 |
    | Test XYZ    | Test  | http://www.test.gov |
    And I am on the boosted contents admin page
    And I follow "Edit"
    And I fill in "Description" with "Bananas"
    And I fill in "Title" with "Bananas"
    And I fill in "Url" with "http://www.bananas.gov"
    And I press "Update"
    When I am on the homepage
    And I fill in "query" with "test"
    And I press "Search"
    Then I should be on the search page
    And I should not see "Test XYZ"
    
    When I am on the homepage
    And I fill in "query" with "bananas"
    And I press "Search"
    Then I should be on the search page
    And I should see "Bananas" within "#boosted"
  
  Scenario: Delete a Boosted Content entry
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Boosted Content entries exist:
    | description | title | url                 |
    | Test XYZ    | Test  | http://www.test.gov |
    And I am on the boosted contents admin page
    And I follow "Delete"
    When I am on the homepage
    And I fill in "query" with "test"
    And I press "Search"
    Then I should be on the search page
    And I should not see "Text XYZ"
