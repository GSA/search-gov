Feature: Affiliate analytics settings
  In order to see my analytics data in different ways
  As a site customer
  I want to change my analytics settings

  @javascript
  Scenario: Setting human vs filtered traffic option
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Analytics page
    And I follow "Settings"
    Then I should see the browser page titled "Settings"
    And I should see "Settings"

    When I choose "Unfiltered (includes both bots + humans)"
    And I submit the form by pressing "Save Settings"
    Then I should see "You have updated your analytics settings."

    When I choose "Filtered (processed via rules to include likely humans only)"
    And I submit the form by pressing "Save Settings"
    Then I should see "You have updated your analytics settings."
