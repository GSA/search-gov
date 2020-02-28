Feature: Affiliate 3rd party tracking
  In order to have 3rd parties collect my usage data
  As a site customer
  I want to upload my JS tracking code

  @javascript
  Scenario: Setting 3rd Party Tracking
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name |
      | aff site     | aff.gov | aff@bar.gov   | John       | Bar       |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Analytics page
    And I follow "3rd Party Tracking"
    Then I should see the browser page titled "3rd Party Tracking"
    And I should see "3rd Party Tracking"

    When I fill in "external_tracking_code" with " "
    And I submit the form by pressing "Submit"
    Then I should see "Web analytics JavaScript code can't be blank"

    When I fill in "external_tracking_code" with "<script>var analytics;</script>"
    And I submit the form by pressing "Submit"
    Then I should see "Your request to update your web analytics code has been submitted."
    And "search@support.digitalgov.gov" should receive an email

    When I open the email
    Then I should see "3rd Party Tracking" in the email subject
    And I should see "Site: aff site" in the email body
    And I should see "Requested by: John Bar <aff@bar.gov>" in the email body
    And I should see "<script>var analytics;</script>" in the email body
