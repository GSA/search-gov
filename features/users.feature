Feature: Users

  @javascript
  Scenario: Logged-in, approved non-developer user visits account page
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the user account page
    Then I should see the browser page titled "My Account"
    And I should see "Contact Information"
    And I should see "First name"
    And I should see "Last name"
    And I should see "Agency"
    And I should see "Email"

  @javascript
  Scenario: User goes to login page and is directed to the security notification first
    Given I go to the login page
    Then I should see "Security Notification"
    And I should see "This is a U.S. General Services Administration Federal Government computer system"

  # to be updated in SRCH-1237 for login.gov
  @wip
  @javascript
  Scenario: Registering as a new affiliate user who is a government employee or contractor with .gov email address
    Given I am on the sign up page
    When I fill in the following:
      | Your first name | Lorem                  |
      | Your last name  | Ipsum                  |
      | Email           | lorem.ipsum@agency.gov |
    And I press "Sign up"
    And I should see "Federal government agency can't be blank"
    When I fill in the following:
      | Your first name           | Lorem                  |
      | Your last name            | Ipsum                  |
      | Email                     | lorem.ipsum@agency.gov |
      | Federal government agency | Agency                 |
    And I press "Sign up"
    Then I should be on the user account page
    When I sign out
    Then I should be on the login page
    And "lorem.ipsum@agency.gov" should receive an email
    When I open the email
    Then I should see "Welcome to Search.gov" in the email subject

  @javascript
  Scenario: Registering as a new affiliate user without government affiliated email address
    Given the following Users exist:
      | first_name   | last_name         | email             |
      | Joe          | Schno             | jschmo@random.com |
    And I am logged in with email "jschmo@random.com"
    Then I should be on the user account page
    And I should see "Because you don't have a .gov or .mil email address, we need additional information."

  @javascript
  Scenario: Logging in as a new approved affiliate user without government affiliated email address
    Given the following Users exist:
      | first_name | last_name         | email             | approval_status |
      | Joe        | Schmo             | jschmo@random.com | approved        |

    And I am logged in with email "jschmo@random.com"
    Then I should be on the user account page
    And I should not see "Because you don't have a .gov or .mil email address, we need additional information."

  @javascript
  Scenario: Visiting edit my account profile page as an affiliate user
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the user account page
    And I follow "Edit"
    Then I should see the browser page titled "Edit My Account"
    And I should see "Edit My Account"
    When I fill in the following:
      | First name        |               |
      | Last name         |               |
      | Government agency |               |
    And I press "Save"
    And I should see "Organization name can't be blank"
    And I should see "First name can't be blank"
    And I should see "Last name can't be blank"
    When I fill in the following:
      | First name        | Elvis          |
      | Last name         | Presley        |
      | Government agency | CIA            |
    And I press "Save"
    Then I should see "Account updated!"
    And I should see "affiliate_admin@fixtures.org"

  # to be updated in SRCH-952 for login.gov
  @wip
  @javascript
  Scenario: A user updates their email to a non-gov address
    Given I am logged in with email "affiliate_admin@fixtures.org"
    And I am on the edit account page
    And I fill in "Email" with "random@random.com"
    And I press "Save"
    Then I should see "Account updated!"
    And "random@random.com" should receive an email
    When I go to the new site page
    Then I should see "Your email address has not been verified."
    And I should be on the user account page
    When I visit the email verification page using the email verification token for "random@random.com"
    Then I should see "Thank you for verifying your email."
    And I should see "Because you don't have a .gov or .mil email address, your account is pending approval."
    And I should be on the user account page

   Scenario: Logging in as a developer user
    Given I am logged in with email "developer@fixtures.org"
    When I go to the user account page
    Then I should see "Our Recalls API Has Moved"
