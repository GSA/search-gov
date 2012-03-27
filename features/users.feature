Feature: Users

  Scenario: Logged-in user visits account page
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    Then I should see the following breadcrumbs: USASearch > My Account
    And I should see "API Key"
    And I should see "Your API key is:"
    And I should see "Contact Information"
    And I should see "Email"
    And I should see "Name"
    And I should see "Phone"
    And I should see "Government organization"
    And I should see "Organization address"
    And I should see "Address 2"
    And I should see "City"
    And I should see "State"
    And I should see "Zip"

  Scenario: Visiting the login page
    Given I am on the login page
    Then I should see a link to "Terms of Service" with url for "http://usasearch.howto.gov/tos" in the registration form

  Scenario: Registering as a new affiliate user who is a government employee or contractor with .gov email address
    Given I am on the login page
    Then I should see "Sign In to Use Our Services"
    And I should see "Register for a New Account"
    And the "I am a government employee or contractor" checkbox should not be checked
    And the "I am not affiliated with a government agency" checkbox should not be checked
    And the "I have read and accept the" checkbox should not be checked
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@agency.gov      |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the affiliate admin page
    And I should see "Thank you for signing up. To continue the signup process, check your inbox, so we may verify your email address."
    And I should see a link to "Admin Center" in the main navigation bar
    When I follow "Sign Out"
    Then I should be on the login page
    And "lorem.ipsum@agency.gov" should receive an email
    When I open the email
    Then I should see "Email Verification" in the email subject
    When I click the first link in the email
    Then I should be on the login page
    Given a clear email queue
    When I fill in the following in the login form:
      | Email                         | lorem.ipsum@agency.gov      |
      | Password                      | huge_secret                 |
    And I press "Login"
    Then I should see "Thank you for verifying your email."
    And "lorem.ipsum@agency.gov" should receive an email
    When I open the email
    Then I should see "Welcome to the USASearch Affiliate Program" in the email subject
    When I follow "Add New Site"
    Then I should be on the new affiliate page

  Scenario: Registering as a new affiliate user with .gov email address and trying to add new site without email verification
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@agency.gov      |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the affiliate admin page
    When I follow "Add New Site"
    Then I should be on the affiliate admin page
    And I should see "Your email address has not been verified. Please check your inbox so we may verify your email address."

  Scenario: Registering as a new affiliate user without government affiliated email address
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@corporate.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the affiliate admin page
    And I should see "Sorry! You don't have a .gov or .mil email address so we need some more information from you before approving your account."
    And I should see a link to "Admin Center" in the main navigation bar
    And I should see "Contact information"
    And the "Name*" field should contain "Lorem Ipsum"
    And the "Email*" field should contain "lorem.ipsum@corporate.com"
    And I fill in the following:
      | Government organization                    | Awesome Agency             |
      | Phone                                      | 202-123-4567               |
      | Organization address                       | 123 Penn Avenue            |
      | Address 2                                  | Ste 456                    |
      | City                                       | Reston                     |
      | Zip                                        | 20022                      |
    And I select "Virginia" from "State"
    And I press "Submit"
    Then I should be on the affiliate admin page
    And I should see "Thank you for providing us your contact information. To continue the signup process, check your inbox, so we may verify your email address."
    When I follow "Sign Out"
    Then I should be on the login page
    And "lorem.ipsum@corporate.com" should receive an email
    When I open the email
    Then I should see "Email Verification" in the email subject
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

  Scenario: Registering as a new affiliate user without government affiliated email address and submitting the contact information form as is
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@corporate.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the affiliate admin page
    And I should see a link to "Admin Center" in the main navigation bar
    And I should see "Contact information"
    And the "Name*" field should contain "Lorem Ipsum"
    And the "Email*" field should contain "lorem.ipsum@corporate.com"
    When I press "Submit"
    Then I should see the browser page titled "Admin Center"
    And I should see "Organization name can't be blank"
    And I should see "Phone can't be blank"
    And I should see "Address can't be blank"
    And I should see "City can't be blank"
    And I should see "Zip can't be blank"

  Scenario: Registering as a new user who is not affiliated with a government agency
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.imsum@notagency.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am not affiliated with a government agency"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should see the browser page titled "My Account"
    And I should see the following breadcrumbs: USASearch > My Account
    And I should see "My Account" in the page header
    And I should see "Thank you for registering for USA.gov Search Services"
    And I should not see a link to "Admin Center" in the main navigation bar
    And I should not see "Add New Affiliate"

  Scenario: Registering as a new affiliate user with a .mil email address
    Given I am on the login page
    And I fill in the following in the new user form:
    | Email                         | lorem.ipsum@agency.mil      |
    | Name                          | Lorem Ipsum                 |
    | Government organization       | The Agency                  |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should see the browser page titled "Admin Center"
    And I should see the following breadcrumbs: USASearch > Admin Center
    And I should see "Admin Center" in the page header
    And I should see "Thank you for signing up. To continue the signup process, check your inbox, so we may verify your email address."
    And I should see a link to "Admin Center" in the main navigation bar

  Scenario: Failing registration as a new affiliate user
    Given I am on the login page
    And I press "Register for a new account"
    Then I should be on the account page
    And I should see "can't be blank"

  Scenario: Registering without selecting government affiliation or accepting the Terms of Service
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.imsum@notagency.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I press "Register for a new account"
    Then I should see "An option for government affiliation must be selected"
    And I should see "Terms of service must be accepted"

  Scenario: Visiting edit my account profile page as an affiliate user
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    And I follow "edit your profile"
    Then I should see the following breadcrumbs: USASearch > My Account > Edit My Account
    And I should see "Edit My Account"
    And I should see "Name"
    And I should see "Government organization"
    And I should see "Email"
    And I should see "Phone"
    And I should see "Organization address"
    And I should see "Address 2"
    And I should see "City"
    And I should see "State"
    And I should see "Zip"
    And I should see "Change password"
    And I should see "Password confirmation"
    And I should not see "I am a government employee or contractor"
    And I should not see "I am not affiliated with a government agency"

   Scenario: Visiting edit my account profile page as a developer user
    Given I am logged in with email "developer@fixtures.org" and password "admin"
    When I go to the user account page
    And I follow "edit your profile"
    Then I should see the following breadcrumbs: USASearch > My Account > Edit My Account
    And I should see "Edit My Account"
    And I should see "Name"
    And I should see "Government organization"
    And I should see "Email"
    And I should not see "Phone"
    And I should not see "Organization address"
    And I should not see "Address 2"
    And I should not see "City"
    And I should not see "State"
    And I should not see "Zip"
    And I should see "Change password"
    And I should see "Password confirmation"
    And I should not see "I am a government employee or contractor"
    And I should not see "I am not affiliated with a government agency"

  Scenario: Adding additional contacts to an affiliate from an account with a single affiliate
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
      | display_name     | name             | contact_email                 | contact_name        |
      | aff site         | aff.gov          | affiliate_admin@fixtures.org  | John Bar            |
    When I go to the user account page
    Then I should see "+ add an additional contact"
    When I follow "+ add an additional contact"
    Then I should be on the "aff site" affiliate users page

  Scenario: Adding additional contacts to an affiliate from an account with multiple affiliates
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
      | display_name     | name             | contact_email                 | contact_name        |
      | aff site         | aff.gov          | affiliate_admin@fixtures.org  | John Bar            |
      | aff site 2       | aff2.gov         | affiliate_admin@fixtures.org  | John Bar            |
    When I go to the user account page
    Then I should see "+ add an additional contact"
    When I follow "+ add an additional contact"
    Then I should be on the user account page
    And I should see "You have multiple sites associated with your account. To add an additional contact, follow these steps"
    When I follow "Admin Center" in the page content
    Then I should see the browser page titled "Admin Center"

  Scenario: User does not see "+ add additional contact when no affiliates are associated with the account"
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    Then I should not see "+ add an additional contact"
