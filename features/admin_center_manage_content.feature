Feature: Manage Content

  Scenario: Viewing Manage Content page after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Manage Content page
    Then I should see "Admin Center"
    And I should see USA.gov selected in the site selector
    And I should see a link to "Manage Content" in the active site main navigation
    And I should see a link to "Content Overview" in the active site sub navigation

  Scenario: View domains
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    When the following site domains exist for the affiliate agency.gov:
      | domain          |
      | whitehouse.gov  |
      | usa.gov         |
      | gobiernousa.gov |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Domains"
    Then I should see the following table rows:
      | gobiernousa.gov |
      | usa.gov         |
      | whitehouse.gov  |

  Scenario: Add/edit/remove domains
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Domains"
    And I follow "Add Domain"
    When I fill in "Domain" with "usa.gov"
    And I press "Add"
    Then I should see "You have added usa.gov to this site"
    When I follow "Edit"
    And I fill in "Domain" with "gobiernousa.gov"
    And I press "Save"
    Then I should see "You have updated gobiernousa.gov"
    When I press "Remove"
    Then I should see "You have removed gobiernousa.gov from this site"

  Scenario: View Flickr URLs
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    When the following flickr URLs exist for the site "agency.gov":
      | url                                      |
      | http://www.flickr.com/photos/whitehouse/ |
      | http://www.flickr.com/groups/usagov/     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Flickr URLs"
    Then I should see the following table rows:
      | www.flickr.com/groups/usagov/     |
      | www.flickr.com/photos/whitehouse/ |

  Scenario: Add/remove Flickr URL
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Flickr URLs"
    And I follow "Add Flickr URL"
    When I fill in "Flickr URL" with "www.flickr.com/groups/usagov/"
    And I press "Add"
    Then I should see "You have added www.flickr.com/groups/usagov/ to this site"
    When I press "Remove"
    Then I should see "You have removed www.flickr.com/groups/usagov/ from this site"
