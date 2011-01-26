Feature: Users

  Scenario: Logged-in user visits account page
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    Then I should see "USASearch > My Account"
    And I should see "API Key"
    And I should see "Your API key is:"
    And I should see "Account Profile"
    And I should see "Email"
    And I should see "Name"
    And I should see "Time Zone"
    And I should see "Phone"
    And I should see "Organization"
    And I should see "Address"
    And I should see "Address Line 2"
    And I should see "City"
    And I should see "State"
    And I should see "Zip"

  Scenario: Registering as a new affiliate user who is a government employee or contractor
    Given I am on the login page
    Then I should see "USASearch > Sign In to Use Our Services"
    And I should see "Register for a New Account"
    And the "I am a government employee or contractor" checkbox should not be checked
    And the "I am not affiliated with a government agency" checkbox should not be checked
    When I fill in the following within "#new_user":
    | Email                         | lorem.ipsum@agency.gov      |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am a government employee or contractor"
    And I press "Register for a new account"
    Then I should be on the affiliate admin page
    And I should see "Thank you for registering for USA.gov Search Services"
    And I should see "Affiliate Center"
    And I should see "Add New Affiliate"

  Scenario: Registering as a new affiliate user who is not affiliated with a government agency
    Given I am on the login page
    Then I should see "USASearch > Sign In to Use Our Services"
    When I fill in the following within "#new_user":
    | Email                         | lorem.imsum@notagency.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am not affiliated with a government agency"
    And I press "Register for a new account"
    Then I should be on the user account page
    And I should see "Thank you for registering for USA.gov Search Services"
    And I should not see "Affiliate Center"
    And I should not see "Add New Affiliate"

  Scenario: Registering as a new affiliate user with a .mil email address
    Given I am on the login page
    And I fill in the following within "#new_user":
    | Email                         | lorem.ipsum@agency.mil      |
    | Name                          | Lorem Ipsum                 |
    | Organization                  | The Agency                  |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am a government employee or contractor"
    And I press "Register for a new account"
    Then I should be on the affiliate admin page
    And I should see "Thank you for registering for USA.gov Search Services"

  Scenario: Failing registration as a new affiliate user
    Given I am on the login page
    And I press "Register for a new account"
    Then I should be on the account page
    And I should see "can't be blank"

  Scenario: Registering without selecting government affiliation
    Given I am on the login page
    When I fill in the following within "#new_user":
    | Email                         | lorem.imsum@notagency.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I press "Register for a new account"
    Then I should see "An option for government affiliation must be selected"

  Scenario: Visiting edit my account profile page as an affiliate user
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the user account page
    And I follow "edit your profile"
    Then I should see "USASearch > Affiliate Program > My Account > Edit"
    And I should see "Edit My Account"
    And I should see "Name"
    And I should see "Organization"
    And I should see "Email"
    And I should see "Phone"
    And I should see "Organization address"
    And I should see "Address line 2"
    And I should see "City"
    And I should see "State"
    And I should see "Zip"
    And I should see "Time zone"
    And I should see "Change password"
    And I should see "Password confirmation"
    And I should not see "I am a government employee or contractor"
    And I should not see "I am not affiliated with a government agency"

   Scenario: Visiting edit my account profile page as a developer user
    Given I am logged in with email "developer@fixtures.org" and password "admin"
    When I go to the user account page
    And I follow "edit your profile"
    Then I should see "USASearch > Affiliate Program > My Account > Edit"
    And I should see "Edit My Account"
    And I should see "Name"
    And I should see "Organization"
    And I should see "Email"
    And I should not see "Phone"
    And I should not see "Organization address"
    And I should not see "Address line 2"
    And I should not see "City"
    And I should not see "State"
    And I should not see "Zip"
    And I should not see "Time zone"
    And I should see "Change password"
    And I should see "Password confirmation"
    And I should not see "I am a government employee or contractor"
    And I should not see "I am not affiliated with a government agency"

