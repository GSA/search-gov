Feature: Analytics Homepage
  In order to anticipate trends and topics of high public interest
  As an analyst
  I want to view analytics on usasearch query data

  Scenario: Viewing the homepage
    Given I am on the analytics homepage
    Then I should see "Yesterday"
    And I should see "Last 7 days"
    And I should see "Last 30 days"
    And I should see "Most Popular"
    And I should see "Biggest Movers"

  Scenario: No data for yesterday
    Given I am on the analytics homepage
    And there are no daily query stats for the last 1 day
    Then I should see "Query data unavailable"

  Scenario: No data for the trailing week
    Given I am on the analytics homepage
    And there are no daily query stats for the last 7 days
    Then I should see "Query data unavailable"

  Scenario: No data for the trailing week
    Given I am on the analytics homepage
    And there are no daily query stats for the last 30 days
    Then I should see "Query data unavailable"
