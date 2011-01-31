Feature: Program
  In order to provide information about hosted search services,
  I want to see information about affiliate program, API / web services and searchUSA.gov

  Scenario: Show links to affiliate program, API / web services and searchUSA.gov
    Given I am on the program welcome page
    Then I should see "USASearch Program" within "title"
    And I should see "Affiliate Program" within ".main"
    And I should see "APIs and other web services" within ".main"
    And I should see "Search.USA.gov" within ".main"

    When I follow "program_logo"
    Then I should be on the program welcome page

    When I fill in "query" with "White House"
    Then I press "Search"
    Then I should be on the search page
    And I should see 10 search results

  Scenario: Visiting Affiliate Program links
    Given I am on the program welcome page
    When I follow "learn_more_affiliates" within ".main"
    Then I should be on the affiliates page
    And I should see "USASearch Affiliate Program" within "title"
    And I should see "USASearch > Affiliate Program"
    And I should see "USASearch Affiliate Program" within ".main"

    When I follow "How It Works"
    Then I should see "How the Affiliate Program Works" within "title"
    And I should see "USASearch > Affiliate Program > How it Works"
    And I should see "How the Affiliate Program Works" within ".main"
    When I follow "Register Now"
    Then I should see "Sign In to Use Our Services"

    When I follow "See it in action"
    Then I should see "See the Affiliate Program in Action" within "title"
    And I should see "USASearch > Affiliate Program > See it in Action"
    And I should see "See the Affiliate Program in Action" within ".main"

    When I follow "sign up"
    And I should see "Sign In to Use Our Services"

    When I follow "Sign in" within "#affiliate_program_nav"
    Then I should see "Sign In to Use Our Services"

    When I follow "Affiliate Program" within ".admin-footer"
    Then I should be on the affiliates page

  Scenario: Visiting APIs and other web services links
    Given I am on the program welcome page
    When I follow "learn_more_api" within ".main"
    Then I should be on the api page
    And I should see "APIs and Web Services" within "title"
    And I should see "USASearch > APIs & Web Services"
    And I should see "APIs and Web Services" within ".main"

    When I follow "APIs & Web Services" within ".nav"
    Then I should be on the api page

    When I follow "APIs & Web Services" within ".admin-footer"
    Then I should be on the api page

    When I follow "Terms of Service"
    Then I should be on the terms of service page
    And I should see "Terms of Service for USASearch's APIs and Web Services" within "title"
    And I should see "USASearch > APIs & Web Services > Terms of Service"
    And I should see "Terms of Service for USASearch's APIs and Web Services" within ".main"

    When I follow "Recalls API" within ".nav"
    Then I should be on the recalls api page
    And I should see "Product Recall Data API" within "title"
    And I should see "USASearch > APIs & Web Services > Recalls API"
    And I should see "Product Recall Data API" within ".main"

    When I follow "Sign in" within "#api_nav"
    Then I should see "Sign In to Use Our Services"

  Scenario: Search.USA.gov link should be on the searchusagov page
    Given I am on the program welcome page
    When I follow "learn_more_searchusagov" within ".main"
    Then I should be on the searchusagov page
    And I should see "Search.USA.gov" within "title"
    And I should see "USASearch > Search.USA.gov"
    And I should see "Search.USA.gov" within ".main"

    When I follow "Search.USA.gov" within ".admin-footer"
    Then I should be on the searchusagov page

    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the search page
    And I should see 10 search results

  Scenario: Visiting API pages as a logged in user
    Given I am logged in with email "developer@fixtures.org" and password "admin"
    When I am on the program welcome page
    And I follow "APIs & Web Services"
    Then I should see "developerapikey"

    When I follow "Product Recall Data API"
    Then I should see "developerapikey"

    When I follow "APIs & Web Services"
    And I follow "Terms of Service"
    Then I should see "developerapikey"

