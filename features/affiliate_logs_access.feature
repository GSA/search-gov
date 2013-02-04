Feature: Affiliate log access
  In order to wade through my own log files
  As an affiliate
  I want to upload my public key to get access


  Scenario: Uploading public key for an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | is_sayt_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Raw logs access"
    Then I should see "Secure FTP Access to Raw HTTP Logs"

    When I attach the file "features/support/id_rsa.pub" to "txtfile"
    And I press "Upload"
    Then I should be on the affiliate admin page
    And I should see "Public key successfully uploaded."

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Raw logs access"
    And I press "Upload"
    Then I should see "Your public key file could not be processed. Please check the format and try again."
