Feature: Manage Display

  Scenario: Editing Sidebar Settings
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes         |
      | Blog | agency.gov/blog/ |
    And affiliate "agency.gov" has the following RSS feeds:
      | name  | url                          |
      | Press | usasearch.howto.gov/all.atom |
    And the following flickr URLs exist for the site "agency.gov":
      | url                                      |
      | http://www.flickr.com/photos/whitehouse/ |
    And the following Twitter handles exist for the site "agency.gov":
      | screen_name |
      | usasearch   |
    And the following YouTube usernames exist for the site "agency.gov":
      | username     |
      | usgovernment |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Display page

    Then the "Results Page Label" field should be blank
    And the "Default search label" field should contain "Everything"
    And the "Image Search Label 0" field should contain "Images"
    And the "Is Image Search Label 0 navigable" checkbox should be checked
    And the "Document Collection 1" field should contain "Blog"
    And the "Is Document Collection 1 navigable" checkbox should be checked
    And the "Rss Feed 2" field should contain "Press"
    And the "Is Rss Feed 2 navigable" checkbox should not be checked
    And the "Rss Feed 3" field should contain "Videos"

    When I fill in the following:
      | Results Page Label    | Search        |
      | Default search label  | Web           |
      | Image Search Label 0  | Latest Images |
      | Document Collection 1 | Latest Blog   |
      | Rss Feed 2            | Latest Press  |
      | Rss Feed 3            | Latest Videos |
    And I uncheck "Is Image Search Label 0 navigable"
    And I uncheck "Is Document Collection 1 navigable"
    And I check "Is Rss Feed 2 navigable"
    And I check "Is Rss Feed 3 navigable"

    And I press "Save"
    Then I should see "You have updated your site display settings"
    And the "Results Page Label" field should contain "Search"
    And the "Default search label" field should contain "Web"
    And the "Image Search Label 0" field should contain "Latest Images"
    And the "Is Image Search Label 0 navigable" checkbox should not be checked
    And the "Document Collection 1" field should contain "Latest Blog"
    And the "Is Document Collection 1 navigable" checkbox should not be checked
    And the "Rss Feed 2" field should contain "Latest Press"
    And the "Is Rss Feed 2 navigable" checkbox should be checked
    And the "Rss Feed 3" field should contain "Latest Videos"
    And the "Is Rss Feed 3 navigable" checkbox should be checked

  Scenario: Editing GovBoxes Settings
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes         |
      | Blog | agency.gov/blog/ |
    And affiliate "agency.gov" has the following RSS feeds:
      | name  | url                          |
      | Press | usasearch.howto.gov/all.atom |
    And the following flickr URLs exist for the site "agency.gov":
      | url                                      |
      | http://www.flickr.com/photos/whitehouse/ |
    And the following Twitter handles exist for the site "agency.gov":
      | screen_name |
      | usasearch   |
    And the following YouTube usernames exist for the site "agency.gov":
      | username     |
      | usgovernment |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Display page

    And the "Rss govbox label" field should contain "News"
    And the "Is rss govbox enabled" checkbox should not be checked
    And the "Is video govbox enabled" checkbox should be checked
    And the "Is photo govbox enabled" checkbox should be checked
    And the "Is jobs govbox enabled" checkbox should not be checked
    And the "Is agency govbox enabled" checkbox should not be checked
    And the "Is related searches enabled" checkbox should be checked
    And the "Is medline govbox enabled" checkbox should not be checked
    And I should see "Recent Tweets"

    When I fill in "Rss govbox label" with "Latest News"
    And I check "Is rss govbox enabled"
    And I uncheck "Is video govbox enabled"
    And I uncheck "Is photo govbox enabled"
    And I check "Is jobs govbox enabled"
    And I check "Is agency govbox enabled"
    And I uncheck "Is related searches enabled"
    And I check "Is medline govbox enabled"

    And I press "Save"
    Then I should see "You have updated your site display settings"
    And the "Rss govbox label" field should contain "Latest News"
    And the "Is rss govbox enabled" checkbox should be checked
    And the "Is video govbox enabled" checkbox should not be checked
    And the "Is photo govbox enabled" checkbox should not be checked
    And the "Is jobs govbox enabled" checkbox should be checked
    And the "Is agency govbox enabled" checkbox should be checked
    And the "Is related searches enabled" checkbox should not be checked
    And the "Is medline govbox enabled" checkbox should be checked

  @javascript
  Scenario: Editing Related Sites
    Given the following Affiliates exist:
      | display_name  | name         | contact_email   | contact_name |
      | agency site 1 | 1.agency.gov | john@agency.gov | John Bar     |
      | agency site 2 | 2.agency.gov | john@agency.gov | John Bar     |
      | agency site 3 | 3.agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the 1.agency.gov's Manage Display page
    And I fill in the following:
      | Connection site handle 0 | 2.agency.gov       |
      | Connection label 0       | agency site 2 SERP |
    When I follow "Add Another Related Site"
    Then I should be able to access 2 related site entries
    When I fill in the following:
      | Connection site handle 1 | 3.agency.gov       |
      | Connection label 1       | agency site 3 SERP |
    And I press "Save"
    Then I should see "You have updated your site display settings"
    And the "Connection site handle 0" field should contain "2.agency.gov"
    And the "Connection label 0" field should contain "agency site 2 SERP"
    And the "Connection site handle 1" field should contain "3.agency.gov"
    And the "Connection label 1" field should contain "agency site 3 SERP"

    And I fill in the following:
      | Connection site handle 0 | |
      | Connection label 0       | |
    And I press "Save"
    Then I should see "You have updated your site display settings"
    And the "Connection site handle 0" field should contain "3.agency.gov"
    And the "Connection label 0" field should contain "agency site 3 SERP"

  Scenario: Editing Font & Color
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Font & Color page
    Then I should see "Font & Color (Coming Soon)"

  Scenario: Editing Image Assets
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Image Assets page
    Then I should see "Image Assets (Coming Soon)"

  Scenario: Editing Advanced Display
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Advanced Display page
    Then I should see "Advanced Display (Coming Soon)"
