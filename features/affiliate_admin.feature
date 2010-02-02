Feature: Affiliate Administration
  In order to see who is using USASearch as an Affiliate and manage their accounts
  As an administrator
  I want to see relevant information for all Affiliates

  Scenario: Visiting the affiliate admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the affiliate admin home page
    Then I should see "Affiliates"
    And I should see "affiliate_admin@fixtures.org"
    And I should see "My Account"
    And I should see "Logout"
    When I follow "Logout"
    Then I should be on the login page

  Scenario: Sending a welcome email to all affiliates
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | single           | one@foo.gov           | One Foo             |
    | multi1           | two@bar.gov           | Two Bar             |
    | multi2           | two@bar.gov           | Two Bar             |
    And a clear email queue
    When I go to the affiliate admin broadcast page
    And I fill in "Subject" with "some title"
    And I fill in "Body" with "This is the email body"
    And I press "Send to all affiliates"
    Then I should be on the affiliate admin home page
    And I should see "Message broadcasted to all affiliates successfully"
    And "one@foo.gov" should receive 1 email
    And "two@bar.gov" should receive 1 email
    When "one@foo.gov" opens the email with subject "some title"
    Then they should see "This is the email body" in the email body
    And they should see "One Foo" in the email body
    And they should see "single" in the email body
    When "two@bar.gov" opens the email with subject "some title"
    Then they should see "This is the email body" in the email body
    And they should see "Two Bar" in the email body
    And they should see "multi1" in the email body
    And they should see "multi2" in the email body
