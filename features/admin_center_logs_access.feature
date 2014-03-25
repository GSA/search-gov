Feature: Affiliate log access
  In order to wade through my own log files line by line
  As a site customer
  I want to upload my public key to get SFTP access

  @javascript
  Scenario: Uploading public key for a site
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | is_sayt_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Analytics page
    And I follow "Raw Logs"

    And I attach the file "features/support/blank.txt" to "txtfile"
    And I submit the form by pressing "Upload"
    Then I should see "Your public key file could not be processed. Please check the format and try again."

    And I attach the file "features/support/id_rsa.pub" to "txtfile"
    And I submit the form by pressing "Upload"
    Then I should land on the aff.gov's Dashboard page
    And I should see "Public key successfully uploaded."
    And "search@support.digitalgov.gov" should receive an email

    When I open the email
    Then I should see "Request for log file access" in the email subject
    And I should see "ssh-rsa AAAAB3NzaC1yc2EAA" in the email body
