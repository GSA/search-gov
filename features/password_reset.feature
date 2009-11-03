Feature: Password Reset

  So that I can reset my password
  As an existing user
  I want to have a password reset email sent to me

  Scenario: I canot login because I cannot remember my account password

    Given I am on the login page
    And I follow "Forgot your password?"
    When I fill in "email" with "affiliate_admin@fixtures.org"
    And I press "Reset my password"
    Then I should be on the password reset page
    And I should see "Instructions to reset your password have been emailed to you"
    And "affiliate_admin@fixtures.org" should receive an email
    When I open the email
    Then I should see "Password Reset Instructions" in the email subject
    When I click the first link in the email
    Then I should see "Change My Password"
    When I fill in "Password" with "changed"
    And I fill in "Password confirmation" with "changed"
    And I press "Update my password and log me in"
    Then I should see "Password successfully updated"
    And I should be on the user account page

  Scenario: I don't confirm my new password properly
    Given I am on the login page
    And I follow "Forgot your password?"
    When I fill in "email" with "affiliate_admin@fixtures.org"
    And I press "Reset my password"
    Then "affiliate_admin@fixtures.org" should receive an email
    When I open the email
    And I click the first link in the email
    And I fill in "Password" with "changed"
    And I fill in "Password confirmation" with "mistyped changed"
    And I press "Update my password and log me in"
    Then I should see "Password doesn't match confirmation"

  Scenario: Trying to reset the password of a user that doesn't exist
    Given I am on the login page
    And I follow "Forgot your password?"
    When I fill in "email" with "notarealuser@fixtures.org"
    And I press "Reset my password"
    Then I should see "No user was found with that email address"
    And I should be on the password reset page
