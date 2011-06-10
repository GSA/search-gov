Feature: Search Module Analytics
  In order to see how various elements on SERPs are performing
  As an Analyst
  I want to view impressions and clicks on search modules broken down by day/affiliate/locale/vertical

  Scenario: Viewing the search module analytics page when data is available
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following search modules exist:
    | tag | display_name |
    | FOO | Foo Module   |
    | BAR | Bar Module   |
    And the following search module data exists for "2011-06-10":
    | affiliate_name | module_tag     | vertical| locale | impressions | clicks |
    | usasearch.gov  | FOO            | web     | en     | 100         | 40     |
    | usasearch.gov  | BAR            | web     | en     | 10          | 9      |
    | usasearch.gov  | FOO            | form    | en     | 10          | 1      |
    | usasearch.gov  | FOO            | image   | es     | 10          | 2      |
    | otheraff.govy  | BAR            | web     | en     | 10          | 3      |
    | otheraff.govy  | UNKNOWN        | recall  | en     | 1           | 1      |
    When I am on the analytics homepage
    And I follow "Search Module Stats"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center > Search Module Stats
    And I should see "Data for June 10, 2011"
    And I should see "Search Module Stats"
    And I should see "Impressions and Clicks by Module"
    And I should see the following table rows:
    | Module      | Impressions     | Clicks | Clickthru Rate |
    | Foo Module  | 120             | 43     | 35%            |
    | Bar Module  | 20              | 12     | 60%            |

  Scenario: Viewing the search module analytics page when data is available
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And no search module data exists
    When I am on the analytics homepage
    And I follow "Search Module Stats"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Analytics Center > Search Module Stats
    And I should see "Search module data currently unavailable"
    And I should not see "Impressions and Clicks by Module"
