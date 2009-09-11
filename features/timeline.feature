Feature: Timeline for query
  In order to see historical details of a query's popularity
  As an Analyst
  I want to view a chart of the number of queries per day over time

  Scenario: Viewing a chart for a given term
    Given there is analytics data from "20090831" thru "20090901"
    And I am on the analytics homepage
    Then I should see "aaaf"
    When I follow "aaaf"
    Then I should be on the timeline page for "aaaf"
    And I should see "Interest over time for 'aaaf'"