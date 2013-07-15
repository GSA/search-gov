Feature: Admin Center

  Scenario: Viewing a site without logging in
    When I go to the USA.gov's site page
    Then I should see "Log In"

  Scenario: Viewing a site after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the USA.gov's site page
    Then I should see "Admin Center"
    And I should see USA.gov selected in the site selector
    And I should see a link titled "Dashboard" in the active site main navigation
    And I should see a link to "Site Overview" in the active site sub navigation

  Scenario: Updating Settings
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the USA.gov's site page
    And I follow "Settings"
    Then I should see USA.gov selected in the site selector
    And I should see a link titled "Dashboard" in the active site main navigation
    And I should see a link to "Settings" in the active site sub navigation
    When I fill in "Site Name" with "agency site"
    And I press "Save Settings"
    Then I should see "Your site settings have been updated"
    When I fill in "Site Name" with ""
    And I press "Save Settings"
    Then I should see "Site name can't be blank"

  @javascript
  Scenario: Clicking on help link
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    And the following Help Links exist:
      | request_path        | help_page_url                                           |
      | /sites/setting/edit | http://usasearch.howto.gov/manual/site-information.html |
    When I go to the USA.gov's site page
    And I follow "Settings"
    Then I should see a link to "Help?" with url for "http://usasearch.howto.gov/manual/site-information.html"
    When I follow "Help?"
    Then I should see a link to "Site Information" with url for "http://usasearch.howto.gov/manual/site-information.html"
