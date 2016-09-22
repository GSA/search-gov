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
    Then I should see "Passwords must contain a minimum of eight (8) characters and include a combination of letters, numbers, and special characters."
    When I fill in the following:
      | Your full name | Lorem Ipsum            |
      | Email          | lorem.ipsum@agency.gov |
      | Password       | test1234!              |
    And I press "Sign up"
    Then I should be on the user account page
    And I should see "Thank you for signing up. To continue the signup process, check your inbox, so we may verify your email address."
    When I sign out
    Then I should be on the login page
    And "lorem.ipsum@agency.gov" should receive the "new_user_email_verification" mandrill email
    Given a clear mandrill email history
    When I visit the email verification page using the email verification token for "lorem.ipsum@agency.gov"
    When I fill in the following:
      | Password | test1234!            |
    And I press "Login"
    Then I should see "Thank you for verifying your email."
    And I should be on the user account page
    And "lorem.ipsum@agency.gov" should receive the "welcome_to_new_user" mandrill email

  Scenario: Registering as a new affiliate user with .gov email address and trying to add new site without email verification
    Given I am on the sign up page
    When I fill in the following:
      | Email          | lorem.ipsum@agency.gov |
      | Your full name | Lorem Ipsum            |
      | Password       | test1234!            |
    And I press "Sign up"
    Then I should be on the user account page
    When I follow "Add Site"
    Then I should be on the user account page
    And I should see "Your email address has not been verified. Please check your inbox so we may verify your email address."

  @javascript
  Scenario: Registering as a new affiliate user without government affiliated email address
    Given I am on the sign up page
    When I fill in the following:
      | Email          | lorem.ipsum@corporate.com |
      | Your full name | Lorem Ipsum               |
      | Password       | test1234!                 |
    And I press "Sign up"
    Then I should be on the user account page
    And I should see "Sorry! You don't have a .gov or .mil email address so we need some more information from you before approving your account."
    When I sign out
    Then I should be on the login page
    And "lorem.ipsum@corporate.com" should receive the "new_user_email_verification" mandrill email
    Given a clear mandrill email history
    When I visit the email verification page using the email verification token for "lorem.ipsum@corporate.com"
    When I fill in the following:
      | Password | test1234!               |
    And I press "Login"
    Then I should see "Thank you for verifying your email."
    And I should see "Because you don't have a .gov or .mil email address, your account is pending approval."
    And "lorem.ipsum@corporate.com" should not have received a mandrill email

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
      | Password          | theking4ever!  |
    And I press "Save"
    Then I should see "Account updated!"
    And I should see "elvis@cia.gov"

   Scenario: Logging in as a developer user
    Given I am logged in with email "developer@fixtures.org"
    When I go to the user account page
    Then I should see "Our Recalls API Has Moved"
