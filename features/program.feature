Feature: Program
  In order to provide information about hosted search services,
  I want to see information about affiliate program, API / web services and searchUSA.gov

  Scenario: Show links to affiliate program, API / web services and searchUSA.gov
    Given I am on the program welcome page
    Then I should see "Affiliate Program" within ".main"
    And I should see "APIs and other web services" within ".main"
    And I should see "Search.USA.gov" within ".main"
    And I should see "Program" within ".breadcrumb"

    When I follow "program_logo"
    Then I should be on the program welcome page

    When I fill in "query" with "White House"
    Then I press "Search"
    Then I should be on the search page
    And I should see 10 search results

  Scenario: Affiliate Program link should be on the affiliates page
    Given I am on the program welcome page
    When I follow "learn_more_affiliates" within ".main"
    Then I should be on the affiliates page
    And I should see "USASearch Affiliate Program"

    When I follow "Affiliate Program" within ".admin-footer"
    Then I should be on the affiliates page

  Scenario: APIs and other web services link should be on the affiliates page
    Given I am on the program welcome page
    When I follow "learn_more_api" within ".main"
    Then I should be on the api page
    And I should see "USASearch APIs"

    When I follow "API & Web Services" within ".nav"
    Then I should be on the api page
    And I should see "API & Web Services" within ".breadcrumb"

    When I follow "API & Web Services" within ".admin-footer"
    Then I should be on the api page

    When I follow "Recalls API" within ".nav"
    Then I should be on the recalls api page
    And I should see "Recalls API" within ".breadcrumb"

  Scenario: Search.USA.gov link should be on the searchusagov page
    Given I am on the program welcome page
    When I follow "learn_more_searchusagov" within ".main"
    Then I should be on the searchusagov page
    And I should see "Search.USA.gov"

    When I follow "Search.USA.gov" within ".admin-footer"
    Then I should be on the searchusagov page
