Feature: Dashboard

  Scenario: Visiting /sites for user with existing sites
    Given the following Affiliates exist:
      | display_name | name         | contact_email      | contact_name |
      | agency1 site | 1.agency.gov | manager@agency.gov | John Manager |
      | agency3 site | 3.agency.gov | manager@agency.gov | John Manager |
    And I am logged in with email "manager@agency.gov" and password "random_string"
    When I go to the sites page
    Then I should see "agency1 site"
    When I go to the 3.agency.gov's Manage Content page
    And I press "Set as my default site"
    Then I should see "You have set agency3 site as your default site"
    And I should see "Manage Content"
    When I go to the sites page
    Then I should see "agency3 site (3.agency.gov)" in the site header

  Scenario: Visiting /sites for user without existing site
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the sites page
    Then I should see "Add a New Site"

  Scenario: Viewing a site without logging in
    When I go to the usagov's Dashboard page
    Then I should see "Log In"

  Scenario: Viewing a site after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Dashboard page
    Then I should see "Admin Center"
    And I should see "USA.gov" in the site header
    And I should see a link to "Dashboard" in the active site main navigation
    And I should see a link to "Site Overview" in the active site sub navigation

  Scenario: Seeing system alerts on the dashboard
    Given the following SystemAlerts exist:
      | message                                                             | start_at   | end_at   |
      | Maintenance window 1 <a href="http://link.to.survey.gov">survey</a> | today      | tomorrow |
      | Maintenance window 2                                                | next month |          |
    And I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Dashboard page
    Then I should see "Maintenance window 1"
    And I should see a link to "survey" with url for "http://link.to.survey.gov"
    And I should not see "Maintenace window 2"

  Scenario: Toggling daily snapshot email
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Dashboard page
    And I press "Send me today's snapshot as a daily email"
    Then I should see "You have enabled the daily snapshot setting for usagov."
    When I press "Stop sending me today's snapshot as a daily email"
    Then I should see "You have disabled the daily snapshot setting for usagov."

  Scenario: Updating Settings
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Dashboard page
    And I follow "Settings"
    Then I should see a link to "Dashboard" in the active site main navigation
    And I should see a link to "Settings" in the active site sub navigation
    And I should see "Site Handle usagov"
    And I should see "Site Language English"
    When I fill in "Display Name" with "agency site"
    And I fill in "Homepage URL" with "http://new.usa.gov"
    And I press "Save Settings"
    Then I should see "Your site settings have been updated"
    And the "Display Name" field should contain "agency site"
    And the "Homepage URL" field should contain "http://new.usa.gov"
    When I fill in "Display Name" with ""
    And I press "Save Settings"
    Then I should see "Display name can't be blank"

    When I go to the gobiernousa's Dashboard page
    And I follow "Settings"
    Then I should see "Site Handle gobiernousa"
    And I should see "Site Language Spanish"

  @javascript
  Scenario: Clicking on help link
    Given the following HelpLinks exist:
      | request_path        | help_page_url                                         |
      | /sites/setting/edit | http://usasearch.howto.gov/sites/manual/settings.html |
      | /sites/preview      | http://usasearch.howto.gov/sites/manual/preview.html  |
    And I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Dashboard page
    And I follow "Settings"
    Then I should be able to access the "How to Edit Your Settings" help page
    When I follow "Preview"
    Then I should be able to access the "How to Preview Your Search Results" help page in the preview layer
    When I close the preview layer
    Then I should be able to access the "How to Edit Your Settings" help page

  Scenario: List users
    Given the following Users exist:
      | contact_name | email               |
      | John Admin   | admin1@fixtures.gov |
      | Jane Admin   | admin2@fixtures.gov |
    And the Affiliate "usagov" has the following users:
      | email               |
      | admin1@fixtures.gov |
      | admin2@fixtures.gov |
    And I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Dashboard page
    And I follow "Manage Users"
    Then I should see the following table rows:
      | Affiliate Manager affiliate_manager@fixtures.org |
      | Jane Admin admin2@fixtures.gov                   |
      | John Admin admin1@fixtures.gov                   |

  Scenario: Add/remove user
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Dashboard page
    And I follow "Manage Users"
    And I follow "Add User"
    When I fill in the following:
      | Name  | Another Admin |
      | Email |  another_affiliate_manager@fixtures.org   |
    And I press "Add"
    Then I should see "You have added another_affiliate_manager@fixtures.org to this site"
    When I follow "Add User"
    And I fill in the following:
      | Name  | Admin Doe |
      | Email |           |
    And I press "Add"
    Then I should see "Email can't be blank"
    When I fill in "Email" with "admin@email.gov"
    And I press "Add"
    Then I should see "notified admin@email.gov on how to login and to access this site"
    When I press "Remove"
    Then I should see "You have removed admin@email.gov from this site"

  @javascript
  Scenario: Preview
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | has_staged_content | uses_managed_header_footer | staged_uses_managed_header_footer | header           | staged_header      | website               |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true               | false                      | false                             | live header text | staged header text | http://www.agency.gov |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Dashboard page
    And I follow "Preview"
    Then the preview layer should be visible
    And I should see a link to "View Staged"
    And I should see a link to "View Current"
    And I should see a link to "View Current Mobile"
    And the preview iframe should contain "staged header text"
    When I follow "View Current"
    Then the preview iframe should contain "live header text"
    When I follow "View Current Mobile"
    Then the preview iframe should contain "agency site Mobile"

  Scenario: Adding a new site
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the new site page
    Then I should see the browser page titled "New Site Setup"

    When I fill in the following:
      | Homepage URL | http://awesome.gov/ |
      | Display Name | Agency Gov          |
      | Site Handle  | x                   |
    And I press "Add"
    Then I should see "Site Handle (visible to searchers in the URL) is too short"
    And the "Homepage URL" field should contain "http://awesome.gov"

    When I fill in the following:
      | Homepage URL | http://usasearch.howto.gov/ |
      | Display Name | Agency Gov                  |
      | Site Handle  | agencygov                   |
    And I choose "Spanish"
    And I press "Add"
    Then I should see "You have added 'Agency Gov' as a site."
    And I should land on the agencygov's Dashboard page
    And "affiliate_manager@fixtures.org" should receive an email

    When I follow "Settings"
    Then the "Homepage URL" field should contain "http://usasearch.howto.gov"

    When I follow "Display"
    And I follow "Image Assets"
    Then the "Favicon URL" field should contain "https://9fddeb862c037f6d2190-f1564c64756a8cfee25b6b19953b1d23.ssl.cf2.rackcdn.com/favicon.ico"

    When I open the email
    Then I should see "Your new site: Agency Gov" in the email subject
    And I should see "Affiliate Manager" in the email body
    And I should see "Name: Agency Gov" in the email body
    And I should see "Handle: agencygov" in the email body

  Scenario: Deleting a site
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Dashboard page
    And I follow "Settings"
    And I press "Delete"
    Then I should land on the new site page
    And I should see "Scheduled site 'USA.gov' for deletion. This could take several hours to complete."
