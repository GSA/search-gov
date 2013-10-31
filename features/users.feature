Feature: Users

  Scenario: Logged-in non-developer user visits account page
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    Then I should see the browser page titled "My Account"
    And I should see "Contact Information"
    And I should see "Name"
    And I should see "Agency"
    And I should see "Email"

  Scenario: Visiting the login page
    Given I am on the login page
    Then I should see a link to "Terms of Service" with url for "http://usasearch.howto.gov/tos" in the registration form

  @javascript
  Scenario: Registering as a new affiliate user who is a government employee or contractor with .gov email address
    Given I am on the login page
    Then I should see "Sign In to Use Our Services"
    And I should see "Register for a New Account"
    And the "I am a government employee or contractor" checkbox should not be checked
    And the "I have read and accept the" checkbox should not be checked
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@agency.gov      |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I check "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the user account page
    And I should see "Thank you for signing up. To continue the signup process, check your inbox, so we may verify your email address."
    When I sign out
    Then I should be on the login page
    And "lorem.ipsum@agency.gov" should receive an email
    When I open the email
    Then I should see "Verify your email" in the email subject
    When I click the first link in the email
    Then I should be on the login page
    Given a clear email queue
    When I fill in the following in the login form:
      | Email                         | lorem.ipsum@agency.gov      |
      | Password                      | huge_secret                 |
    And I press "Login"
    Then I should see "Thank you for verifying your email."
    And I should be on the user account page
    And "lorem.ipsum@agency.gov" should receive an email
    When I open the email
    Then I should see "Welcome to USASearch" in the email subject

  Scenario: Registering as a new affiliate user with .gov email address and trying to add new site without email verification
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@agency.gov      |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I check "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the user account page
    When I follow "Add Site"
    Then I should be on the user account page
    And I should see "Your email address has not been verified. Please check your inbox so we may verify your email address."

  @javascript
  Scenario: Registering as a new affiliate user without government affiliated email address
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@corporate.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I check "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the user account page
    And I should see "Sorry! You don't have a .gov or .mil email address so we need some more information from you before approving your account."
    When I sign out
    Then I should be on the login page
    And "lorem.ipsum@corporate.com" should receive an email
    When I open the email
    Then I should see "Verify your email" in the email subject
    When I click the first link in the email
    Then I should be on the login page
    Given a clear email queue
    When I fill in the following in the login form:
      | Email                         | lorem.ipsum@corporate.com   |
      | Password                      | huge_secret                 |
    And I press "Login"
    Then I should see "Thank you for verifying your email."
    And I should see "Because you don't have a .gov or .mil email address, your account is pending approval."
    And "lorem.ipsum@corporate.com" should receive no emails

  Scenario: Failing registration as a new affiliate user
    Given I am on the login page
    And I press "Register for a new account"
    Then I should be on the account page
    And I should see "can't be blank"

  Scenario: Registering without asserting government affiliation or accepting the Terms of Service
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.imsum@notagency.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I press "Register for a new account"
    Then I should see "Affiliation with government is required to register for an account"
    And I should see "Terms of service must be accepted"

  Scenario: Visiting edit my account profile page as an affiliate user
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    And I follow "Edit"
    Then I should see the browser page titled "Edit My Account"
    And I should see "Edit My Account"
    And I should see "Name"
    And I should see "Agency"
    And I should see "Email"
    And I should see "Change password"
    And I should see "Password confirmation"

   Scenario: Logging in as a developer user
    Given I am logged in with email "developer@fixtures.org" and password "admin"
    When I go to the user account page
    Then I should see "Our Recalls API Has Moved"
