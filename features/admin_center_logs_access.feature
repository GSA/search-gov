Feature: Affiliate log access
  In order to wade through my own log files line by line
  As a site customer
  I want to upload my public key to get SFTP access


  Scenario: Uploading public key for a site
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | is_sayt_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Analytics page
    And I follow "Raw Logs"
    Then I should see "Raw Logs"

    When I press "Upload"
    Then I should see "Your public key file could not be processed. Please check the format and try again."

    When I attach the file "features/support/id_rsa.pub" to "txtfile"
    And I press "Upload"
    Then I should land on the aff.gov's Dashboard page
    And I should see "Public key successfully uploaded."
    And "***REMOVED***" should receive an email

    When I open the email
    Then I should see "Request for log file access" in the email subject
    And I should see "ssh-rsa AAAAB3NzaC1yc2EAA" in the email body

