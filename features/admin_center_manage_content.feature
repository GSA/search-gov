Feature: Manage Content

  Scenario: Viewing Manage Content page after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Manage Content page
    Then I should see "Admin Center"
    And I should see USA.gov selected in the site selector
    And I should see a link to "Manage Content" in the active site main navigation
    And I should see a link to "Content Overview" in the active site sub navigation

  Scenario: View best bets texts
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    When the following Boosted Content entries exist for the affiliate "agency.gov"
      | url                                                 | title                               | description        | status   | publish_start_on | publish_end_on |
      | http://usasearch.howto.gov/releases/2013-05-31.html | Notes for Week Ending May 31, 2013  | multimedia gallery | active   | 2013-08-01       | 2022-01-01     |
      | http://usasearch.howto.gov/releases/2013-06-21.html | Notes for Week Ending June 21, 2013 | spring cleaning    | inactive |                  |                |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text"
    Then I should see the following table rows:
      | Notes for Week Ending June 21, 2013 |
      | Notes for Week Ending May 31, 2013  |
    And I should see "Status: Active"
    And I should see "Published between 08/01/2013 and 01/01/2022"

  @javascript
  Scenario: Add/edit/remove best bets texts
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text"
    And I follow "Add Best Bets: Text"
    When I fill in the following:
      | URL                | http://usasearch.howto.gov/releases/2013-06-21.html |
      | Title              | Notes for Week Ending June 21, 2013                 |
      | Description        | spring cleaning                                     |
      | Keyword 1          | releases                                            |
    And I select "Active" from "Status"
    And I add the following keywords:
      | keyword |
      | rails   |
      | recalls |
    And I press "Add"
    Then I should see "You have added Notes for Week Ending June 21, 2013 to this site"
    And I should see "Status: Active"
    And I should see the following best bets text keywords:
      | keyword  |
      | rails    |
      | recalls  |
      | releases |
    When I follow "Edit"
    And I fill in "Title" with "Release for Week Ending June 21, 2013"
    And I press "Save"
    Then I should see "You have updated Release for Week Ending June 21, 2013"
    When I press "Remove"
    Then I should see "You have removed Release for Week Ending June 21, 2013 from this site"

  Scenario: Bulk upload best bets texts
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text"
    And I follow "Bulk Upload"
    And I attach the file "features/support/boosted_content.csv" to "best_bets_text_data_file"
    And I press "Upload"
    Then I should see "You have added 2 Best Bets: Texts."

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
    And I follow "Flickr"
    Then I should see the following table rows:
      | www.flickr.com/groups/usagov/     |
      | www.flickr.com/photos/whitehouse/ |

  Scenario: Add/remove Flickr URL
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Flickr"
    And I follow "Add Flickr URL"
    When I fill in "Flickr URL" with "www.flickr.com/groups/usagov/"
    And I press "Add"
    Then I should see "You have added www.flickr.com/groups/usagov/ to this site"
    When I press "Remove"
    Then I should see "You have removed www.flickr.com/groups/usagov/ from this site"

  Scenario: View Twitter Handles
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    When the following Twitter handles exist for the site "agency.gov":
      | screen_name |
      | usasearch   |
      | usagov      |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Twitter"
    Then I should see the following table rows:
      | @usagov    |
      | @USASearch |

  Scenario: Add/remove Twitter Handle
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Twitter"
    And I follow "Add Twitter Handle"
    When I fill in "Twitter Handle" with "usasearch"
    And I check "Show tweets from my lists"
    And I press "Add"
    Then I should see "You have added @USASearch to this site"
    And I should see a link to "@USASearch (show lists)" with url for "https://twitter.com/USASearch"
    When I press "Remove"
    Then I should see "You have removed @USASearch from this site"
    When I follow "Add Twitter Handle"
    When I fill in "Twitter Handle" with "usasearch101"
    And I press "Add"
    Then I should see "Screen name is not found"

  Scenario: View YouTube Usernames
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And the following YouTube usernames exist for the site "agency.gov":
      | username     |
      | usgovernment |
      | gobiernousa  |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "YouTube"
    Then I should see the following table rows:
      | gobiernousa  |
      | usgovernment |

  Scenario: Add/remove YouTube Username
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "YouTube"
    And I follow "Add YouTube Username"
    When I fill in "YouTube Username" with " USGovernment "
    And I press "Add"
    Then I should see "You have added usgovernment to this site"
    And I should see a link to "usgovernment" with url for "http://www.youtube.com/user/usgovernment"
    When I press "Remove"
    Then I should see "You have removed usgovernment from this site"
    When I follow "Add YouTube Username"
    When I fill in "YouTube Username" with "usasearch"
    And I press "Add"
    Then I should see "Username is not found"
