Feature: Password Reset

  So that I can reset my password
  As an existing user
  I want to have a password reset email sent to me

  Scenario: I canot login because I cannot remember my account password
    Given I am on the login page
    And I follow "Forgot your password?"
    When I fill in "email" with "affiliate_admin@fixtures.org"
    And I press "Email me a link to reset my password"
    Then I should be on the password reset page
    And I should see "Instructions to reset your password have been emailed to you"
    And "affiliate_admin@fixtures.org" should receive an email
    When I open the email
    Then I should see "Reset your password" in the email subject
    And I should see "https://localhost:3000/password_resets" in the email body
    When I visit the password reset page using the perishable token for "affiliate_admin@fixtures.org"
    When I fill in "Password" with "changed1!"
    And I press "Reset my password and log me in"
    Then I should see "Password successfully updated"
    And I should be on the user account page

  Scenario: I don't confirm my new password properly
    Given I am on the login page
    And I follow "Forgot your password?"
    When I fill in "email" with "affiliate_admin@fixtures.org"
    And I press "Email me a link to reset my password"
    Then "affiliate_admin@fixtures.org" should receive an email
    When I open the email
    And I should see "https://localhost:3000/password_resets" in the email body
    When I visit the password reset page using the perishable token for "affiliate_admin@fixtures.org"
    And I fill in "Password" with ""
    And I press "Reset my password and log me in"
    Then I should see "Password is too short"

  Scenario: My password reset link is invalid
    When I visit the password reset page using the token "invalid_token"
    Then I should be on the new password reset page
    And I should see "Sorry! This password reset link is invalid or expired."

  Scenario: Trying to reset the password of a user that doesn't exist
    Given I am on the login page
    And I follow "Forgot your password?"
    When I fill in "email" with "notarealuser@fixtures.org"
    And I press "Email me a link to reset my password"
    Then I should see "Instructions to reset your password have beenemailed to you. Please check your email."
    And I should be on the password reset page

  Scenario: Trying to reuse the same password
    Given I am on the login page
    And I follow "Forgot your password?"
    When I fill in "email" with "affiliate_admin@fixtures.org"
    And I press "Email me a link to reset my password"
    When I visit the password reset page using the perishable token for "affiliate_admin@fixtures.org"
    And I fill in "Password" with "test1234!"
    And I press "Reset my password and log me in"
    Then I should see "Password is invalid: new password must be different from current password"
