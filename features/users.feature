Feature: Users

  @javascript
  Scenario: Logged-in non-developer user visits account page
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the user account page
    Then I should see the browser page titled "My Account"
    And I should see "Contact Information"
    And I should see "Name"
    And I should see "Agency"
    And I should see "Email"

  @javascript
  Scenario: Registering as a new affiliate user who is a government employee or contractor with .gov email address
    Given I am on the sign up page
    When I fill in the following:
      | Your full name | Lorem Ipsum            |
      | Email          | lorem.ipsum@agency.gov |
      | Password       | short                  |
    And I press "Sign up"
    Then I should see "Your new password must be different from your old password. Passwords must contain a minimum of eight (8) characters and include a combination of letters, numbers, and special characters. Passwords are good for 90 days."
    And I should see "Federal government agency can't be blank"
    When I fill in the following:
      | Your full name            | Lorem Ipsum            |
      | Email                     | lorem.ipsum@agency.gov |
      | Password                  | test1234!              |
      | Federal government agency | Agency                 |
    And I press "Sign up"
    Then I should be on the user account page
    And I should see "Thank you for signing up. To continue the signup process, check your inbox, so we may verify your email address."
    When I sign out
    Then I should be on the login page
    And "lorem.ipsum@agency.gov" should receive an email
    When I open the email
    Then I should see "Verify your email" in the email subject
    And I should see "https://localhost:3000/email_verification" in the email body
    When I visit the email verification page using the email verification token for "lorem.ipsum@agency.gov"
    Then I should be on the login page
    Given a clear email queue
    Then the "Email" field should contain "lorem.ipsum@agency.gov"
    When I fill in the following:
      | Password | test1234!            |
    And I press "Login"
    Then I should see "Thank you for verifying your email."
    And I should be on the user account page
    And "lorem.ipsum@agency.gov" should receive an email
    When I open the email
    Then I should see "Welcome to Search.gov" in the email subject

  Scenario: Registering as a new affiliate user with .gov email address and trying to add new site without email verification
    Given I am on the sign up page
    When I fill in the following:
      | Email                     | lorem.ipsum@agency.gov |
      | Your full name            | Lorem Ipsum            |
      | Password                  | test1234!              |
      | Federal government agency | Agency                 |
    And I press "Sign up"
    Then I should be on the user account page
    When I follow "Add Site"
    Then I should be on the user account page
    And I should see "Your email address has not been verified. Please check your inbox so we may verify your email address."

  @javascript
  Scenario: Registering as a new affiliate user without government affiliated email address
    Given I am on the sign up page
    When I fill in the following:
      | Email                     | lorem.ipsum@corporate.com |
      | Your full name            | Lorem Ipsum               |
      | Password                  | test1234!                 |
      | Federal government agency | Agency                    |
    And I press "Sign up"
    Then I should be on the user account page
    And I should see "Sorry! You don't have a .gov or .mil email address so we need some more information from you before approving your account."
    When I sign out
    Then I should be on the login page
    And "lorem.ipsum@corporate.com" should receive an email
    When I open the email
    Then I should see "Verify your email" in the email subject
    And I should see "https://localhost:3000/email_verification" in the email body
    When I visit the email verification page using the email verification token for "lorem.ipsum@corporate.com"
    Then I should be on the login page
    Given a clear email queue
    When I fill in the following:
      | Password | test1234!               |
    And I press "Login"
    Then I should see "Thank you for verifying your email."
    And I should see "Because you don't have a .gov or .mil email address, your account is pending approval."
    And "lorem.ipsum@corporate.com" should receive no emails

  Scenario: Failing registration as a new affiliate user
    Given I am on the sign up page
    And I press "Sign up"
    Then I should see "Email can't be blank"
    And I should see "Password is too short"

  @javascript
  Scenario: Visiting edit my account profile page as an affiliate user
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the user account page
    And I follow "Edit"
    Then I should see the browser page titled "Edit My Account"
    And I should see "Edit My Account"
    When I fill in the following:
      | Name              | Elvis          |
      | Government agency | CIA            |
      | Email             | elvis@cia.gov  |
      | New Password      | theking4ever!  |
    And I press "Save"
    Then I should see "Current password is invalid"
    When I fill in the following:
      | Name              | Elvis          |
      | Government agency | CIA            |
      | Email             | elvis@cia.gov  |
      | New Password      | test1234!      |
      | Current Password  | test1234!      |
    And I press "Save"
    Then I should see "Password is invalid: new password must be different from current password"
    When I fill in the following:
      | Name              | Elvis          |
      | Government agency | CIA            |
      | Email             | elvis@cia.gov  |
      | New Password      | theking4ever!  |
      | Current Password  | test1234!      |
    And I press "Save"
    Then I should see "Account updated!"
    And I should see "elvis@cia.gov"
    And "elvis@cia.gov" should receive an email

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
