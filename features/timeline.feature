Feature: Timeline for query
  In order to see historical details of a query's popularity
  As an Analyst
  I want to view a chart of the number of queries per day over time

  Scenario: Viewing a chart for a given term
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times |  days_back   |
    | cenobitic                   | 100   |     1        |
    | oxaluria                    | 90    |     1        |
    | finochio                    | 80    |     1        |
    | burmannia                   | 40    |     1        |
    And the following DailyPopularQueries exist for yesterday:
    | query     | times | is_grouped  | time_frame  |
    | cenobitic | 100   | false       | 1           |
    | oxaluria  | 90    | false       | 1           |
    | finochio  | 80    | false       | 1           |
    | burmannia | 40    | false       | 1           |
    | group1    | 180   | true        | 1           |
    And I am on the analytics queries page
    Then I should see "cenobitic"
    And I should see "oxaluria"
    And I should see "finochio"
    And I should see "burmannia"
    When I follow "cenobitic"
    Then I should be on the timeline page for "cenobitic"
    And I should see "Interest over time for 'cenobitic'"
    
  Scenario: Adding a comparison term to the chart
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times |  days_back   |
    | cenobitic                   | 100   |     1        |
    | oxaluria                    | 90    |     1        |
    | finochio                    | 80    |     1        |
    | burmannia                   | 40    |     1        |
    And I am on the timeline page for "cenobitic"
    Then the "Add a comparison term" field should be empty
    When I fill in "Add a comparison term" with "oxaluria"
    And I press "Compare"
    Then I should be on the timeline page for "cenobitic"
    And I should see "Interest over time for 'cenobitic' compared to 'oxaluria'"
    And the "Add a comparison term" field should contain "oxaluria"
    And I should see "Remove: oxaluria"
    When I follow "Remove: oxaluria"
    Then I should be on the timeline page for "cenobitic"
    And I should see "Interest over time for 'cenobitic'"
    And I should not see "oxaluria"

  Scenario: Viewing a chart for a given query group
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times |  days_back   |
    | cenobitic                   | 100   |     1        |
    | oxaluria                    | 90    |     1        |
    | finochio                    | 80    |     1        |
    | burmannia                   | 40    |     1        |
    And the following query groups exist:
      | group    | queries               |
      | group1   | cenobitic, finochio   |
    And the following DailyPopularQueries exist for yesterday:
    | query     | times | is_grouped  | time_frame  |
    | cenobitic | 100   | false       | 1           |
    | oxaluria  | 90    | false       | 1           |
    | finochio  | 80    | false       | 1           |
    | burmannia | 40    | false       | 1           |
    | group1    | 180   | true        | 1           |    
    And I am on the analytics queries page
    Then I should see "group1"
    When I follow "group1"
    Then I should see "Interest over time for 'group1'"
    And I should see a query group comparison term form

  Scenario: Adding a comparison term to a query group timeline
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    And the following DailyQueryStats exist:
    | query                       | times |  days_back   |
    | cenobitic                   | 100   |     1        |
    | oxaluria                    | 90    |     1        |
    | finochio                    | 80    |     1        |
    | burmannia                   | 40    |     1        |
    And the following query groups exist:
      | group    | queries               |
      | group1   | cenobitic, finochio   |
    And the following DailyPopularQueries exist for yesterday:
    | query     | times | is_grouped  | time_frame  |
    | cenobitic | 100   | false       | 1           |
    | oxaluria  | 90    | false       | 1           |
    | finochio  | 80    | false       | 1           |
    | burmannia | 40    | false       | 1           |
    | group1    | 180   | true        | 1           |
    And I am on the analytics queries page
    Then I should see "group1"
    When I follow "group1"
    And I fill in "Add a comparison term" with "oxaluria"
    And I press "Compare"
    Then I should see "Interest over time for 'group1' compared to 'oxaluria'"
    And the "Add a comparison term" field should contain "oxaluria"
    And I should see "Remove: oxaluria"
    When I follow "Remove: oxaluria"
    Then I should see "Interest over time for 'group1'"
    And I should not see "oxaluria"
    And I should see a query group comparison term form
