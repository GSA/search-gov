Feature: User sessions

  @javascript
  Scenario: Already logged-in user visits login page
    Given I am logged in with email "affiliate_admin@fixtures.org"
    And I go to the login page
    Then I should be on the admin home page

  Scenario: Affiliate manager should be on the site home page upon successful login
    When I log in with email "affiliate_manager@fixtures.org"
    Then I should be on the gobiernousa's Dashboard page

  Scenario: Affiliate admin should be on the admin home page upon successful login
    When I log in with email "affiliate_admin@fixtures.org"
    Then I should be on the admin home page

  Scenario: User is not approved
    When I log in with email "affiliate_manager_with_not_approved_status@fixtures.org"
    Then I should see "Security Notification"
    And I should see "These credentials are not recognized as valid for accessing Search.gov. Please reach out to search@support.digitalgov.gov if you believe this is in error."

  Scenario: User's session expires after 1 hour
    Given the following Users exist:
      | first_name | last_name | email            | approval_status |
      | Jane       | doe       | jane@example.com | approved        |
    And the time is 2017-03-30 10:55
    And I am logged in with email "jane@example.com"
    And the time becomes 2017-03-30 12:00
    And I follow "Add Site"
    Then I should be on the login page

  @javascript
  Scenario: Already logged-in super admin logs out
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the admin home page
    Then I should not see "Security Notification"
    When I follow "Sign Out"
    And I go to the admin home page
    Then I should see "Security Notification"

  @javascript
  Scenario: Already logged-in user logs out
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    Then I should not see "Security Notification"
    When I sign out
    And I go to the usagov's Dashboard page
    Then I should see "Security Notification"
