Feature: Developers
  In order to support third-party developers who utilize Search.USA.gov APIs
  As a develiper
  I want to create and manage my developer account 
  
  Scenario: Developers home page
    Given I am on the developers home page
    Then I should see "Register to Use APIs and Web Services"
    And I should see "Login"
    And I should see "Sign up"
    
  Scenario: Register new developer
    Given I am on the developers home page
    And I fill in the following:
    | Email                 | dev@thidparty.com |
    | Contact name          | Joe Dev           |
    | Enter password              | password          |
    | Password confirmation | password          |
    And I press "Register"
    Then I should be on the user account page
    And I should see "Thank you for registering for USA.gov Search Services"
    And I should not see "You currently have no affiliates"
  
  Scenario: Developer does not provide adequate information
    Given I am on the developers home page
    And I fill in the following:
    | Contact name          | Joe Dev           |
    | Password              | password          |
    | Password confirmation | password          |
    And I press "Register"
    Then I should be on the developers signup page
    And I should see "There were problems with the following fields"