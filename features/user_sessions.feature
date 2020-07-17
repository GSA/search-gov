Feature: User sessions

  @javascript
  Scenario: Already logged-in user visits login page
    Given I am logged in with email "affiliate_admin@fixtures.org"
    And I go to the login page
    Then I should see "Contact Information"

  Scenario: Affiliate manager should be on the site home page upon successful login
    When I am logged in with email "affiliate_manager@fixtures.org"
    Then I should be on the gobiernousa's Dashboard page

  Scenario: User is not approved
    Given I am logged in with email "affiliate_manager_with_not_approved_status@fixtures.org"
    Then I should be on the login page
    And I should see "These credentials are not recognized as valid for accessing Search.gov. Please reach out to search@support.digitalgov.gov if you believe this is in error."

  # to be updated in SRCH-945 for login.gov
  @wip
  Scenario: User's session expires after 1 hour
    Given the following Users exist:
      | first_name | last_name | email            | approval_status |
      | Jane       | doe       | jane@example.com | approved        |
    And the time is 2017-03-30 10:55
    And I am logged in with email "jane@example.com"
    And the time becomes 2017-03-30 12:00
    And I follow "Add Site"
    Then I should be on the login page
