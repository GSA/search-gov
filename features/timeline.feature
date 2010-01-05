Feature: Timeline for query
  In order to see historical details of a query's popularity
  As an Analyst
  I want to view a chart of the number of queries per day over time

  Scenario: Viewing a chart for a given term
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist for yesterday:
    | query                       | times |
    | cenobitic                   | 100   |
    | oxaluria                    | 90    |
    | finochio                    | 80    |
    | burmannia                   | 40    |
    And I am on the analytics homepage
    Then I should see "cenobitic"
    And I should see "oxaluria"
    And I should see "finochio"
    And I should see "burmannia"
    When I follow "cenobitic"
    Then I should be on the timeline page for "cenobitic"
    And I should see "Interest over time for 'cenobitic'"