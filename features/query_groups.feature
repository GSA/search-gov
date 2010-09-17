Feature: Manage query_groups
  In order to get a better picture of what query analytics by grouping specific queries
  As an Analyst Admin (i.e., an Analyst with administrative privileges)
  I want to be able to manage query groupings

  Scenario: Bulk editing the queries in a query group
    Given I am logged in with email "analyst_admin@fixtures.org" and password "admin"
    And the following query groups exist:
    | group     | queries               |
    | hcreform  | medicaid, health care |
    And I am on the query groups admin page
    And I follow "Bulk Edit"
    Then I should be on the bulk edit query groups page
    And I should see "Bulk Edit Query Group: hcreform"
    And the "Queries" field should contain "^health care\nmedicaid$"

    When I fill in "grouped_queries_text" with the following text:
      """
      obama health care
      health care reform
      """
    And I press "Update Queries"
    Then I should be on the bulk edit query groups page
    And I should see "2 queries added, 2 queries removed."
    And the "Queries" field should contain "^health care reform\nobama health care$"

    When I fill in "grouped_queries_text" with the following text:
      """
      health care
      health care

      health care reform
      barack obama health care
      """
    And I press "Update Queries"
    Then I should be on the bulk edit query groups page
    And I should see "2 queries added, 1 queries removed."
    And the "Queries" field should contain "^barack obama health care\nhealth care\nhealth care reform$"

    When I fill in "grouped_queries_text" with ""
    And I press "Update Queries"
    Then I should be on the bulk edit query groups page
    And I should see "3 queries removed."
    And the "Queries" field should contain ""

  Scenario: Navigating from the bulk edit query page to the query groups admin page
    Given I am logged in with email "analyst_admin@fixtures.org" and password "admin"
    And the following query groups exist:
    | group     | queries               |
    | hcreform  | medicaid, health care |
    And I am on the query groups admin page
    And I follow "Bulk Edit"
    Then I should be on the bulk edit query groups page
    And I should see "Bulk Edit Query Group: hcreform"
    And I should see "Back to Query Groups Admin"
    When I follow "Back to Query Groups Admin"
    Then I should be on the query groups admin page

  Scenario: Accessing the analytics dashboard as a plain analyst
    Given I am logged in with email "analyst@fixtures.org" and password "admin"
    When I am on the analytics homepage
    Then I should not see "Query Groups Admin"

  Scenario: Accessing the analytics dashboard as an affiliate admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I am on the analytics homepage
    Then I should not see "Query Groups Admin"

  Scenario: Accessing the analytics dashboard as an analyst admin
    Given I am logged in with email "marilyn@fixtures.org" and password "admin"
    When I am on the analytics homepage
    Then I should see "Query Groups Admin"
    When I follow "Query Groups Admin"
    Then I should be on the query groups admin page
