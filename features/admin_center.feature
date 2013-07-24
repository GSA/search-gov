Feature: Admin Center

  Scenario: Viewing a site without logging in
    When I go to the usagov's site page
    Then I should see "Log In"

  Scenario: Viewing a site after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's site page
    Then I should see "Admin Center"
    And I should see USA.gov selected in the site selector
    And I should see a link to "Dashboard" in the active site main navigation
    And I should see a link to "Site Overview" in the active site sub navigation

  Scenario: Updating Settings
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's site page
    And I follow "Settings"
    Then I should see USA.gov selected in the site selector
    And I should see a link to "Dashboard" in the active site main navigation
    And I should see a link to "Settings" in the active site sub navigation
    When I fill in "Site Name" with "agency site"
    And I press "Save Settings"
    Then I should see "Your site settings have been updated"
    When I fill in "Site Name" with ""
    And I press "Save Settings"
    Then I should see "Site name can't be blank"

  @javascript
  Scenario: Clicking on help link
    Given the following HelpLinks exist:
      | request_path        | help_page_url                                           |
      | /sites/setting/edit | http://usasearch.howto.gov/manual/site-information.html |
    And I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's site page
    And I follow "Settings"
    Then I should see a link to "Help?" with url for "http://usasearch.howto.gov/manual/site-information.html"
    When I follow "Help?"
    Then I should see a link to "Site Information" with url for "http://usasearch.howto.gov/manual/site-information.html"

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
    When I go to the usagov's site page
    And I follow "Manage Users"
    Then I should see the following table rows:
      | Affiliate Manager affiliate_manager@fixtures.org |
      | Jane Admin admin2@fixtures.gov                   |
      | John Admin admin1@fixtures.gov                   |

  Scenario: Add/remove user
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's site page
    And I follow "Manage Users"
    And I follow "Add User"
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
      | display_name | name       | contact_email   | contact_name | has_staged_content | managed_header_text | staged_managed_header_text | managed_header_home_url | staged_managed_header_home_url | mobile_homepage_url | staged_mobile_homepage_url |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true               | live header text    | staged header text         | live.home.agency.gov    | staged.home.agency.gov         | m.live.agency.gov   | m.staged.agency.gov        |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's site page
    And I follow "Preview"
    Then I should see a link to "View Staged"
    And I should see a link to "View Current"
    And I should see a link to "View Staged Mobile"
    And I should see a link to "View Current Mobile"
    And the preview iframe should contain a link to "http://staged.home.agency.gov"
    When I follow "View Current"
    Then the preview iframe should contain a link to "http://live.home.agency.gov"
    When I follow "View Staged Mobile"
    Then the preview iframe should contain a link to "http://m.staged.agency.gov"
    When I follow "View Current Mobile"
    Then the preview iframe should contain a link to "http://m.live.agency.gov"

