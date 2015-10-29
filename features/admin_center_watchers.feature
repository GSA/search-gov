Feature: Watchers (aka Analytics Alerts)
  In order to get notified of certain events around my site
  As a site customer
  I want to set up and manage various alerts

  Scenario: View watchers
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And we don't want observers to run during these cucumber scenarios
    And user john@agency.gov has created the following No Results watchers for agency.gov:
      | name             | throttle_period   | check_interval     | time_window | distinct_user_total |
      | Second  One      | 12h               | 10m                | 2w          | 100                 |
      | First One        | 1w                | 1h                 | 1d          | 50                  |
    And user john@agency.gov has created the following Low Query CTR watchers for agency.gov:
      | name             | throttle_period   | check_interval     | time_window | search_click_total  | low_ctr_threshold |
      | Third One        | 12h               | 10m                | 2w          | 1000                | 15.5              |
      | Fourth One       | 1w                | 1h                 | 1d          | 50                  | 25                |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Analytics page
    And I follow "Analytics Alerts"
    Then I should see the following table rows:
      | Name             | Type                   | Alert Threshold                    | Time Window | Check Every... | Time Between Alerts |
      | First One        | No Results Watcher     | 50 Queries                         | 1d          | 1h             | 1w                  |
      | Fourth One       | Low Query Ctr Watcher  | 25% CTR on 50 Queries & Clicks     | 1d          | 1h             | 1w                  |
      | Second One       | No Results Watcher     | 100 Queries                        | 2w          | 10m            | 12h                 |
      | Third One        | Low Query Ctr Watcher  | 15.5% CTR on 1000 Queries & Clicks | 2w          | 10m            | 12h                 |
    And we want observers to run during the rest of these cucumber scenarios

  @javascript
  Scenario: Add/edit/remove watchers
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And we don't want observers to run during these cucumber scenarios
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Analytics page
    And I follow "Analytics Alerts"
    Then I should see "You don't have any Analytics Alerts defined yet"

    When I follow "Create a No Results alert"
    And I fill in the following:
      | Name                  |                 |
      | Throttle Period       | 1w              |
      | Check Interval        | 1h              |
      | Time Window           | 1d              |
      | Ignored Query Terms   | brandon, jobs   |
      | Search Count          | 50              |
    And I submit the form by pressing "Add"
    Then I should see "There were problems with the following fields"

    When I fill in the following:
      | Name                  | First One       |
      | Throttle Period       | 1w              |
      | Check Interval        | 1h              |
      | Time Window           | 1d              |
      | Ignored Query Terms   | brandon, jobs   |
      | Search Count          | 50              |
    And I submit the form by pressing "Add"
    Then I should see the following table rows:
      | Name             | Type                   | Alert Threshold | Time Window | Check Every... | Time Between Alerts |
      | First One        | No Results Watcher     | 50 Queries      | 1d          | 1h             | 1w                  |
    And I should see "You have created a watcher"

    When I follow "Edit" within the first table body row
    And I fill in "Name" with ""
    And I submit the form by pressing "Save"
    Then I should see "There were problems with the following fields"

    When I fill in "Name" with "Changed name"
    And I submit the form by pressing "Save"
    Then I should see "This watcher has been updated."

    When I press "Remove" within the first table body row
    Then I should see "You have removed the watcher"
    And I should see "You don't have any Analytics Alerts defined yet"
    And we want observers to run during the rest of these cucumber scenarios
