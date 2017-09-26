Feature: Dashboard

  Scenario: Visiting /sites for user with existing sites
    Given the following Affiliates exist:
      | display_name | name         | contact_email      | contact_name |
      | agency1 site | 1.agency.gov | manager@agency.gov | John Manager |
      | agency3 site | 3.agency.gov | manager@agency.gov | John Manager |
    And I am logged in with email "manager@agency.gov"
    When I go to the sites page
    Then I should see "agency1 site"
    When I go to the 3.agency.gov's Manage Content page
    And I follow "Set as my default site"
    Then I should see "You have set agency3 site as your default site"
    And I should see "Manage Content"
    When I go to the sites page
    Then I should see "agency3 site (3.agency.gov)" in the site header

  Scenario: Visiting /sites for user without existing site
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org"
    When I go to the sites page
    Then I should see "Add a New Site"

  Scenario: Viewing a site without logging in
    When I go to the usagov's Dashboard page
    Then I should see "Login" button

  Scenario: Viewing a site after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    Then I should see "USA.gov" in the site header
    And I should see a link to "Dashboard" in the active site main navigation
    And I should see a link to "Site Overview" in the active site sub navigation

  Scenario: Seeing system alerts on the dashboard
    Given the following SystemAlerts exist:
      | message                                                             | start_at   | end_at   |
      | Maintenance window 1 <a href="http://link.to.survey.gov">survey</a> | today      | tomorrow |
      | Maintenance window 2                                                | next month |          |
    And I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    Then I should see "Maintenance window 1"
    And I should see a link to "survey" with url for "http://link.to.survey.gov"
    And I should not see "Maintenace window 2"

  Scenario: Toggling daily snapshot email
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Send me today's snapshot as a daily email"
    Then I should see "You have enabled the daily snapshot setting for usagov."
    When I follow "Stop sending me today's snapshot as a daily email"
    Then I should see "You have disabled the daily snapshot setting for usagov."

  @javascript
  Scenario: Toggling filtered analytics
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Stop filtering bot traffic"
    Then I should see "You're no longer filtering bot traffic. Analytics include both humans and bots."
    When I follow "Filter bot traffic"
    Then I should see "You're now filtering bot traffic. Analytics include likely humans only."

  @javascript
  Scenario: Updating Settings
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Settings"
    Then I should see a link to "Dashboard" in the active site main navigation
    And I should see a link to "Settings" in the active site sub navigation
    And I should see "Site Handle usagov"
    And I should see "Site Language English"
    When I fill in "Display Name" with "agency site"
    And I fill in "Homepage URL" with "http://new.usa.gov"
    And I submit the form by pressing "Save Settings"
    Then I should see "Your site settings have been updated"
    And the "Display Name" field should contain "agency site"
    And the "Homepage URL" field should contain "http://new.usa.gov"
    When I fill in "Display Name" with ""
    And I submit the form by pressing "Save Settings"
    Then I should see "Display name can't be blank"

    When I go to the gobiernousa's Dashboard page
    And I follow "Settings"
    Then I should see "Site Handle gobiernousa"
    And I should see "Site Language Spanish"

  @javascript
  Scenario: Cloning a site
    Given the following Affiliates exist:
      | display_name | name         | contact_email      | contact_name |
      | origin site  | origin_site  | john@agency.gov    | John Manager |
    And I am logged in with email "john@agency.gov"
    When I go to the origin_site's Dashboard page
    And I follow "Clone Site"
    Then I should see a link to "Dashboard" in the active site main navigation
    And I should see a link to "Clone Site" in the active site sub navigation
    And I should see "Clone Site"
    When I fill in "New Site Handle" with "abcd012345678900123456789001234567890"
    And I submit the form by pressing "Submit"
    Then I should see "Validation failed: Site Handle (visible to searchers in the URL) is too long"

    When I fill in "New Site Handle" with "usagov_copy"
    And I submit the form by pressing "Submit"
    Then I should see "Site 'origin_site' has been cloned as 'usagov_copy'"
    And I should land on the usagov_copy's Dashboard page

  @javascript
  Scenario: Clicking on help link on Admin Center
    Given the following HelpLinks exist:
      | request_path        | help_page_url                                      |
      | /sites/setting/edit | https://search.digitalgov.gov/manual/settings.html |
    And I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Settings"
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
    And I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Manage Users"
    Then I should see the following table rows:
      | Affiliate Manager affiliate_manager@fixtures.org            |
      | Jane Admin admin2@fixtures.gov (Pending email verification) |
      | John Admin admin1@fixtures.gov (Pending email verification) |

  @javascript
  Scenario: Add/remove user
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Manage Users"
    And I follow "Add User"
    When I fill in the following:
      | Name  | Another Admin |
      | Email |  another_affiliate_manager@fixtures.org   |
    And I submit the form by pressing "Add"
    Then I should see "You have added another_affiliate_manager@fixtures.org to this site"
    When I follow "Add User"
    And I fill in the following:
      | Name  | Admin Doe |
      | Email |           |
    And I submit the form by pressing "Add"
    Then I should see "Email can't be blank"
    When I fill in "Email" with "admin@email.gov"
    And I submit the form by pressing "Add"
    Then I should see "notified admin@email.gov on how to login and to access this site"
    When I press "Remove" within the first table body row
    Then I should see "You have removed admin@email.gov from this site"

  @javascript
  Scenario: Complete sign up process
    Given no emails have been sent
    And I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Manage Users"
    And I follow "Add User"
    When I fill in the following:
      | Name  | Jane Admin     |
      | Email | jane@admin.org |
    And I submit the form by pressing "Add"
    And I sign out
    Then "jane@admin.org" should receive the "welcome_to_new_user_added_by_affiliate" mandrill email
    When I visit the complete registration page using the email verification token for "jane@admin.org"
    Then the "Your full name" field should contain "Jane Admin"
    Then the "Email" field should contain "jane@admin.org"
    When I fill in the following:
      | Federal government agency | My Agency   |
      | Password                  | test1234!   |
    And I press "Complete the sign up process"
    Then I should see "Site Overview"

  @javascript
  Scenario: Add existing user to site
    Given a clear mandrill email history
    And I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Manage Users"
    And I follow "Add User"
    When I fill in the following:
      | Name  | Marylin Admin        |
      | Email | marilyn@fixtures.org |
    And I submit the form by pressing "Add"
    And I sign out
    Then "marilyn@fixtures.org" should receive the "new_affiliate_user" mandrill email

  @javascript
  Scenario: Preview
    Given the following Affiliates exist:
      | display_name | name              | contact_email   | contact_name | has_staged_content | uses_managed_header_footer | staged_uses_managed_header_footer | header           | staged_header      | website               | force_mobile_format |
      | agency site  | legacy.agency.gov | john@agency.gov | John Bar     | true               | false                      | false                             | live header text | staged header text | http://www.agency.gov | false               |
      | agency site  | www.agency.gov    | john@agency.gov | John Bar     | true               | false                      | false                             | live header text | staged header text | http://www.agency.gov | true                |
    And I am logged in with email "john@agency.gov"
    When I go to the legacy.agency.gov's Dashboard page
    And I follow "Preview"
    Then I should find "View Staged Page" in the Preview modal
    And I should find "View Current Page" in the Preview modal
    And I should find "View Redesigned Page" in the Preview modal

    When I go to the www.agency.gov's Dashboard page
    And I follow "Preview"
    Then I should see a link to "Preview" with url that ends with "/search?affiliate=www.agency.gov"

  @javascript
  Scenario: Adding a new site
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the new site page
    Then I should see the browser page titled "New Site Setup"

    When I fill in the following:
      | Homepage URL | http://awesome.gov/ |
      | Display Name | Agency Gov          |
      | Site Handle  | x                   |
    And I submit the form by pressing "Add"
    Then I should see "Site Handle (visible to searchers in the URL) is too short"
    And the "Homepage URL" field should contain "http://awesome.gov"

    When I fill in the following:
      | Homepage URL | https://search.digitalgov.gov/ |
      | Display Name | Agency Gov                     |
      | Site Handle  | agencygov                      |
    And I select "Arabic" from "Site Language"
    And I submit the form by pressing "Add"
    Then I should see "You have added 'Agency Gov' as a site."
    And I should land on the agencygov's Dashboard page
    And "affiliate_manager@fixtures.org" should receive an email

    When I follow "Settings"
    Then the "Homepage URL" field should contain "https://search.digitalgov.gov"
    And I should see "Arabic"

    When I follow "Content"
    Then the "Discover and add the RSS feeds and social media accounts listed on the following page:" field should contain "https://search.digitalgov.gov"

    When I follow "Display"
    And I follow "Image Assets"
    Then the "Favicon URL" field should contain "https://d3qcdigd1fhos0.cloudfront.net/blog/img/favicon.ico"

    When I open the email
    Then I should see "Your new site: Agency Gov" in the email subject
    And I should see "Affiliate Manager" in the email body
    And I should see "Name: Agency Gov" in the email body
    And I should see "Handle: agencygov" in the email body

  Scenario: Performing site autodiscovery
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | has_staged_content | uses_managed_header_footer | staged_uses_managed_header_footer | header           | staged_header      | force_mobile_format |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true               | false                      | false                             | live header text | staged header text | false               |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    Then the "Discover and add the RSS feeds and social media accounts listed on the following page:" field should be empty
    And the "autodiscovery_url" input should be required

    When I fill in the following:
      | Discover and add the RSS feeds and social media accounts listed on the following page: | http:// bad |
    And I press "Discover"
    Then I should see "Invalid site URL"
    And the "Discover and add the RSS feeds and social media accounts listed on the following page:" field should contain "http:// bad"

    When I fill in the following:
      | Discover and add the RSS feeds and social media accounts listed on the following page: | https://search.usa.gov |
    And I press "Discover"
    Then I should see "Discovery complete for https://search.usa.gov"
    And the "Discover and add the RSS feeds and social media accounts listed on the following page:" field should contain "https://search.usa.gov"

  Scenario: Deleting a site
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Settings"
    And I press "Delete"
    Then I should land on the new site page
    And I should see "Scheduled site 'USA.gov' for deletion. This could take several hours to complete."

  @javascript
  Scenario: Sending an idea
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    And I follow "Settings"
    And I follow "Send an Idea"
    #Disabling this brittle test in anticipation of it being removed entirely:
    #https://www.pivotaltracker.com/story/show/145755437
    #Then I should find UserVoice widget
