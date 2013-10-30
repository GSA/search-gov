Feature: Search Module Analytics
  In order to see how various elements on SERPs are performing
  As an Analyst
  I want to view impressions and clicks on search modules broken down by day/affiliate/locale/vertical

  Scenario: Viewing the search module analytics page when data is available
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
      | display_name  | name          | contact_email | contact_name |
      | bureau.gov    | bureau.gov    | two@bar.gov   | Two Bar      |
      | otheraff.govy | otheraff.govy | two@bar.gov   | Two Bar      |
    And the following search modules exist:
      | tag | display_name |
      | FOO | Foo Module   |
      | BAR | Bar Module   |
    And the following search module data exists for "2011-06-10":
      | affiliate_name | module_tag | vertical | locale | impressions | clicks |
      | bureau.gov     | FOO        | web      | en     | 100         | 40     |
      | bureau.gov     | BAR        | web      | en     | 10          | 9      |
      | bureau.gov     | FOO        | form     | en     | 10          | 1      |
      | bureau.gov     | FOO        | image    | es     | 10          | 2      |
      | otheraff.govy  | BAR        | web      | en     | 10          | 3      |
      | otheraff.govy  | UNKNOWN    | recall   | en     | 1           | 1      |
    And the following search module data exists for "2011-06-11":
      | affiliate_name | module_tag | vertical | locale | impressions | clicks |
      | bureau.gov     | FOO        | web      | en     | 100         | 40     |
      | bureau.gov     | BAR        | web      | en     | 10          | 9      |
      | bureau.gov     | FOO        | form     | en     | 10          | 1      |
      | bureau.gov     | FOO        | image    | es     | 10          | 2      |
      | otheraff.govy  | BAR        | web      | en     | 10          | 3      |
      | otheraff.govy  | UNKNOWN    | recall   | en     | 1           | 1      |
    And the following search module data exists for "2011-06-12":
      | affiliate_name | module_tag | vertical | locale | impressions | clicks |
      | bureau.gov     | FOO        | web      | en     | 100         | 40     |
      | bureau.gov     | BAR        | web      | en     | 10          | 9      |
      | bureau.gov     | FOO        | form     | en     | 10          | 1      |
      | bureau.gov     | FOO        | image    | es     | 10          | 2      |
      | otheraff.govy  | BAR        | web      | en     | 10          | 3      |
      | otheraff.govy  | UNKNOWN    | recall   | en     | 1           | 1      |
    When I am on the admin home page
    And I follow "Search Module Stats"
    Then I should see "Search Module Stats"
    And I should see "Impressions and Clicks by Module"
    And I should see the following table rows:
      | Module     | Impressions | Clicks | Clickthru Rate |
      | Foo Module | 360         | 129    | 35.8%          |
      | Bar Module | 60          | 36     | 60.0%          |
      | Total      | 420         | 165    | 39.3%          |
    When I fill in "start_date" with "2011-06-10"
    And I fill in "end_date" with "2011-06-11"
    And I select "Image" from "Vertical"
    And I select "bureau.gov" from "Affiliate"
    And I press "Submit"
    Then I should see the following table rows:
      | Module     | Impressions | Clicks | Clickthru Rate |
      | Foo Module | 20          | 4      | 20.0%          |
      | Total      | 20          | 4      | 20.0%          |
    When I fill in "start_date" with "2011-06-10"
    And I fill in "end_date" with "2011-06-10"
    And I select "bureau.gov" from "Affiliate"
    And I select "Recall" from "Vertical"
    And I press "Submit"
    Then I should see "No data matched your filters"

  Scenario: Viewing the search module analytics page when data is NOT available
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
      | display_name  | name          | contact_email | contact_name |
      | bureau.gov    | bureau.gov    | two@bar.gov   | Two Bar      |
      | otheraff.govy | otheraff.govy | two@bar.gov   | Two Bar      |
    And no search module data exists
    When I am on the admin home page
    And I follow "Search Module Stats"
    Then I should see "No data matched your filters"
