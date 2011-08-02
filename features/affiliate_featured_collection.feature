Feature: Featured Collections
  As an affiliate manager
  I want to manage feature collections
  So that I can share them with my search users

  Scenario: Visiting Featured Collections index page
    Given the following Affiliates exist:
      | display_name | name     | contact_email              | contact_name |
      | site         | site.gov | affiliate_manager@site.gov | John Bar     |
    And the following featured collections exist for the affiliate "site.gov":
      | title                                                                                                      | title_url                | locale | status   |
      | Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis at tincidunt erat. Sed sit amet massa massa. | http://site.gov/content5 | en     | active   |
    And I am logged in with email "affiliate_manager@site.gov" and password "random_string"
    When I go to the site.gov's featured collections page
    Then I should see the browser page titled "Featured Collections"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > site > Featured Collections
    And I should see "Featured Collections" in the page header
    And I should see "Add new featured collection"
    And I should see "Lorem ipsum dolor sit amet,..."
    And I should see "Active"
    When there are 30 featured collections exist for the affiliate "site.gov":
      | locale | status |
      | en     | active |
    And I go to the site.gov's featured collections page
    Then I should see "20" featured collections
    When I follow "Next"
    Then I should see "random title 20"

  Scenario: Adding Featured Collection
    Given the following Affiliates exist:
      | display_name | name     | contact_email              | contact_name |
      | site         | site.gov | affiliate_manager@site.gov | John Bar     |
    And I am logged in with email "affiliate_manager@site.gov" and password "random_string"
    When I go to the site.gov's featured collections page
    Then I should see "Site site has no Featured Collection"
    And I follow "Add new featured collection"
    Then I should see the browser page titled "Add a new Featured Collection"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > site > Add a new Featured Collection
    And I should see "Add a new Featured Collection" in the page header
    When I follow "Cancel"
    Then I should see "Featured Collections" in the page header

    When I follow "Add new featured collection"
    And I fill in the following:
      | Title*       | 2010 Atlantic Hurricane Season                    |
      | Title URL    | http://www.nhc.noaa.gov/2010atlan.shtml           |
      | Keyword 0    | weather                                           |
      | Link Title 0 | Hurricane Alex                                    |
      | Link URL 0   | http://www.nhc.noaa.gov/pdf/TCR-AL012010_Alex.pdf |
    And I select "English" from "Locale*"
    And I select "Active" from "Status*"
    And I press "Add"
    Then I should see "Feature Collection successfully created"
    And I should see the browser page titled "Featured Collection: 2010 Atlantic Hurricane Season"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > site > Featured Collection: 2010 Atlantic Hurricane Season
    And I should see "Featured Collection: 2010 Atlantic Hurricane Season" in the page header
    And I should see "2010 Atlantic Hurricane Season"
    And I should see "http://www.nhc.noaa.gov/2010atlan.shtml"
    And I should see "English"
    And I should see "Active"
    And I should see a link to "Hurricane Alex" with url for "http://www.nhc.noaa.gov/pdf/TCR-AL012010_Alex.pdf"
    When I follow "Edit"
    And I should see the browser page titled "Edit Featured Collection"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > site > Edit Featured Collection
    And I should see "Edit Featured Collection" in the page header
    And the "Title*" field should contain "2010 Atlantic Hurricane Season"
    And the "Title URL" field should contain "http://www.nhc.noaa.gov/2010atlan.shtml"
    And the "Keyword 0" field should contain "weather"

  Scenario: Adding Featured Collection without filling out the required fields
    Given the following Affiliates exist:
      | display_name | name     | contact_email              | contact_name |
      | site         | site.gov | affiliate_manager@site.gov | John Bar     |
    And I am logged in with email "affiliate_manager@site.gov" and password "random_string"
    When I go to the site.gov's featured collections page
    And I follow "Add new featured collection"
    And I fill in the following:
      | Link Title 0 | 2010 Atlantic Hurricane Season          |
      | Link URL 1   | http://www.nhc.noaa.gov/2010atlan.shtml |
    And I press "Add"
    Then I should see "Title can't be blank"
    And I should see "Locale must be selected"
    And I should see "Status must be selected"
    And I should see "Featured collection links title can't be blank"
    And I should see "Featured collection links url can't be blank"

  Scenario: Editing Featured Collection
    Given the following Affiliates exist:
      | display_name | name     | contact_email              | contact_name |
      | site         | site.gov | affiliate_manager@site.gov | John Bar     |
    And the following featured collections exist for the affiliate "site.gov":
      | title                            | title_url                                | locale | status |
      | Worldwide Tropical Cyclone Names | http://www.nhc.noaa.gov/aboutnames.shtml | en     | active |
    And the following featured collection keywords exist for featured collection titled "Worldwide Tropical Cyclone Names":
      | value        |
      | weather      |
      | hurricane    |
      | thunderstorm |
    And the following featured collection links exist for featured collection titled "Worldwide Tropical Cyclone Names":
      | title                 | url                                          |
      | Atlantic              | http://www.nhc.noaa.gov/aboutnames.shtml#atl |
      | Eastern North Pacific | http://www.nhc.noaa.gov/aboutnames.shtml#enp |
    And I am logged in with email "affiliate_manager@site.gov" and password "random_string"
    When I go to the site.gov's featured collections page
    And I follow "Edit"
    And I should see the browser page titled "Edit Featured Collection"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > site > Edit Featured Collection
    And I should see "Edit Featured Collection" in the page header
    When I follow "Cancel"
    Then I should see "Featured Collection: Worldwide Tropical Cyclone Names" in the page header

    When I follow "Edit"
    And I fill in the following:
      | Title        | Australian Tropical Cyclone                                                                                |
      | Title URL    | http://australiasevereweather.com/cyclones/                                                                |
      | Keyword 0    | typhoon                                                                                                    |
      | Keyword 1    | cyclone                                                                                                    |
      | Keyword 2    |                                                                                                            |
      | Link Title 0 | 2010-2011 Season Southern Hemisphere Summary                                                               |
      | Link URL 0   | http://australiasevereweather.com/tropical_cyclones/oper_2010_2011_australian_region_tropical_cyclones.htm |
      | Link Title 1 |                                                                                                            |
      | Link URL 1   |                                                                                                            |
    And I press "Update"
    Then I should see "Featured Collection successfully updated."
    And I should see the browser page titled "Featured Collection: Australian Tropical Cyclone"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > site > Featured Collection: Australian Tropical Cyclone
    And I should see "Featured Collection: Australian Tropical Cyclone" in the page header
    And I should see "typhoon"
    And I should see "cyclone"
    And I should not see "thunderstorm"
    And I should see a link to "2010-2011 Season Southern Hemisphere Summary" with url for "http://australiasevereweather.com/tropical_cyclones/oper_2010_2011_australian_region_tropical_cyclones.htm"
    And I should not see "Atlantic"
    And I should not see "Eastern North Pacific"

  Scenario: Editing Featured Collection without filling out the required fields
    Given the following Affiliates exist:
      | display_name | name     | contact_email              | contact_name |
      | site         | site.gov | affiliate_manager@site.gov | John Bar     |
    And the following featured collections exist for the affiliate "site.gov":
      | title                            | title_url                                | locale | status |
      | Worldwide Tropical Cyclone Names | http://www.nhc.noaa.gov/aboutnames.shtml | en     | active |
    And the following featured collection keywords exist for featured collection titled "Worldwide Tropical Cyclone Names":
      | value        |
      | weather      |
      | hurricane    |
      | thunderstorm |
    And the following featured collection links exist for featured collection titled "Worldwide Tropical Cyclone Names":
      | title                 | url                                          |
      | Atlantic              | http://www.nhc.noaa.gov/aboutnames.shtml#atl |
      | Eastern North Pacific | http://www.nhc.noaa.gov/aboutnames.shtml#enp |
    And I am logged in with email "affiliate_manager@site.gov" and password "random_string"
    When I go to the site.gov's featured collections page
    And I follow "Edit"
    And I fill in the following:
      | Title        |  |
      | Link Title 0 |  |
      | Link URL 1   |  |
    And I select "Select a locale" from "Locale*"
    And I select "Select a status" from "Status*"
    And I press "Update"
    Then I should see "Title can't be blank"
    And I should see "Locale must be selected"
    And I should see "Status must be selected"
    And I should see "Featured collection links title can't be blank"
    And I should see "Featured collection links url can't be blank"

  Scenario: Deleting Featured Collection
    Given the following Affiliates exist:
      | display_name | name     | contact_email              | contact_name |
      | site         | site.gov | affiliate_manager@site.gov | John Bar     |
    And the following featured collections exist for the affiliate "site.gov":
      | title                                                                                                      | title_url                | locale | status   |
      | Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis at tincidunt erat. Sed sit amet massa massa. | http://site.gov/content5 | en     | active   |
    And I am logged in with email "affiliate_manager@site.gov" and password "random_string"
    When I go to the site.gov's featured collections page
    And I press "Delete"
    Then I should see "Featured Collection successfully deleted"
    And I should see the browser page titled "Featured Collections"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > site > Featured Collections
    And I should see "Featured Collections" in the page header
