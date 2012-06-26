Feature: Timeline for query
  In order to see historical details of a query's popularity
  As an Affiliate
  I want to view a chart of the number of queries per day over time

  Scenario: Viewing a chart for a given term
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist:
    | query                       | times | affiliate     | locale |  days_back   |
    | social pollution            | 70    | aff.gov       | en     |      1       |
    | jobs                        | 60    | aff.gov       | en     |      1       |
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query logs"
    And I follow "social pollution"
    Then I should see "Query Timeline" within "title"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Query Timeline
    And I should see "Interest over time for 'social pollution'"
    When I fill in "Add a comparison term" with "jobs"
    And I press "Compare"
    Then I should see "Interest over time for 'social pollution' compared to 'jobs'"
    When I follow "Remove: jobs"
    Then I should see "Interest over time for 'social pollution'"
    And I should not see "Remove: jobs"

  Scenario: Search for a term and view the chart
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And the following DailyQueryStats exist:
    | query                       | times | affiliate     | locale |  days_back   |
    | social pollution            | 70    | aff.gov       | en     |      1       |
    | irs                         | 50    | aff.gov       | en     |      1       |
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query logs"
    And I fill in "query" with "pollution"
    And I press "Search"
    Then I should see "Matches for 'pollution'"
    When I follow "social pollution"
    Then I should see "Interest over time for 'social pollution'"
    When I fill in "Add a comparison term" with "irs"
    And I press "Compare"
    Then I should see "Interest over time for 'social pollution' compared to 'irs'"
    When I follow "Remove: irs"
    Then I should see "Interest over time for 'social pollution'"
    And I should not see "Remove: irs"
