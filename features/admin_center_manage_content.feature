@javascript
Feature: Manage Content

  Scenario: Viewing Manage Content page after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Manage Content page
    Then I should see a link to "Content" in the active site main navigation
    And I should see a link to "Content Overview" in the active site sub navigation

  Scenario: View best bets graphics
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And the following featured collections exist for the affiliate "agency.gov":
      | title           | title_url                         | status   | publish_start_on | publish_end_on | keywords     |
      | Tornado Warning | http://agency.gov/tornado-warning | active   | 2013-07-01       |                |              |
      | Flood Watches   |                                   | inactive | 2013-08-01       |                |              |
      | Fire Safety     |                                   | active   | 2013-09-01       | 2013-09-30     | burn,lighter |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Graphics" within the Admin Center content
    Then I should see "Graphic Best Bets are being deprecated due to low usage. Please use Text Best Bets instead."
    And I should not see a link to "Add Best Bets: Graphics"
    And I should see the following table rows:
      | Fire Safety     |
      | Flood Watches   |
      | Tornado Warning |
    And I should see a link to "Tornado Warning" with url for "http://agency.gov/tornado-warning"
    And I should see "Published between 09/01/2013 and 09/30/2013"
    And I should see "Status: Inactive"

  Scenario: Filtering best bets graphics
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And the following featured collections exist for the affiliate "agency.gov":
      | title           | title_url                         | status   | publish_start_on | publish_end_on | keywords     |
      | Tornado Warning | http://agency.gov/tornado-warning | active   | 2013-07-01       |                |              |
      | Flood Watches   |                                   | inactive | 2013-08-01       |                |              |
      | Fire Safety     |                                   | active   | 2013-09-01       | 2013-09-30     | burn,lighter |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Graphics" within the Admin Center content
    Then I should see "Graphic Best Bets are being deprecated due to low usage. Please use Text Best Bets instead."
    And I should not see a link to "Add Best Bets: Graphics"
    And I fill in "query" with "lighter"
    And I press "Search"
    Then I should see the following table rows:
      | Fire Safety     |
    And I should see "Showing matches for 'lighter'"
    And I fill in "query" with "lksdjflskdjf"
    And I press "Search"
    Then I should see "No Best Bets found matching 'lksdjflskdjf'"
    When I follow "Reset"
    Then I should be on the agency.gov's Best Bets Graphics page

  Scenario: Add/edit/remove best bets graphics
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And the following featured collections exist for the affiliate "agency.gov":
      | title                        | title_url                         | status | publish_start_on | publish_end_on | keywords     | image_file_path              | image_alt_text   | match_keyword_values_only |
      | 2010 Atlantic Hurricane Season | http://www.nhc.noaa.gov/2010atlan.shtml | active | 2013-07-01       | 07/01/2030     | storm,weather | features/support/small.jpg | hurricane logo   | true                      |
    And the following featured collection links exist for featured collection titled "2010 Atlantic Hurricane Season":
      | title              | url                                                   | position |
      | Hurricane Alex     | http://www.nhc.noaa.gov/pdf/TCR-AL012010_Alex.pdf     | 0        |
      | Hurricane Danielle | http://www.nhc.noaa.gov/pdf/TCR-AL062010_Danielle.pdf | 1        |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Graphics" within the Admin Center content
    Then I should see "Graphic Best Bets are being deprecated due to low usage. Please use Text Best Bets instead."
    And I should not see a link to "Add Best Bets: Graphics"
    And I should see a link to "2010 Atlantic Hurricane Season" with url for "http://www.nhc.noaa.gov/2010atlan.shtml"
    And I should see "Status: Active"
    And I should see "Match Keywords Only"
    And I should see the following best bets keywords:
      | keyword |
      | storm   |
      | weather |
    When I follow "Edit"
    Then I should see the following:
      | Title                 | 2010 Atlantic Hurricane Season                        |
      | Title URL             | http://www.nhc.noaa.gov/2010atlan.shtml               |
      | Publish End Date      | 07/01/2030                                            |
      | Image Alt Text        | hurricane logo                                        |
      | Link Title 1          | Hurricane Alex                                        |
      | Link URL 1            | http://www.nhc.noaa.gov/pdf/TCR-AL012010_Alex.pdf     |
      | Link Title 2          | Hurricane Danielle                                    |
      | Link URL 2            | http://www.nhc.noaa.gov/pdf/TCR-AL062010_Danielle.pdf |
    And I should see an s3 image "small.jpg"
    When I fill in "Title" with "2011 Atlantic Hurricane Season"
    And I check "Mark Image for Deletion"
    And I uncheck "Match Keywords Only?"
    And I submit the form by pressing "Save"
    Then I should see "You have updated 2011 Atlantic Hurricane Season"
    And I should not see "Match Keywords Only"
    When I follow "Edit"
    Then I should not see "Mark Image for Deletion"

    When I fill in the following:
      | Link Title 1 | Hurricane Alex                                        |
      | Link URL 1   |                                                       |
      | Link Title 2 |                                                       |
      | Link URL 2   | http://www.nhc.noaa.gov/pdf/TCR-AL062010_Danielle.pdf |
    And I submit the form by pressing "Save"
    Then I should see "2 errors prohibited this featured collection from being saved"
    Then I should see "There were problems with the following fields:"
    Then I should see "Best bets: graphics links title can't be blank"
    Then I should see "Best bets: graphics links url can't be blank"

    When I follow "View All"
    And I press "Remove" and confirm "Are you sure you wish to remove 2011 Atlantic Hurricane Season from this site?"
    Then I should see "You have removed 2011 Atlantic Hurricane Season from this site"

  Scenario: View best bets texts
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    When the following Boosted Content entries exist for the affiliate "agency.gov"
      | url                                        | title                               | description        | status   | publish_start_on | publish_end_on |
      | http://search.gov/releases/2013-05-31.html | Notes for Week Ending May 31, 2013  | multimedia gallery | active   | 2013-08-01       | 2022-01-01     |
      | http://search.gov/releases/2013-06-21.html | Notes for Week Ending June 21, 2013 | spring cleaning    | inactive |                  |                |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text" within the Admin Center content
    Then I should see the following table rows:
      | Notes for Week Ending June 21, 2013 |
      | Notes for Week Ending May 31, 2013  |
    And I should see "Status: Active"
    And I should see "Published between 08/01/2013 and 01/01/2022"

  Scenario: Filtering best bets texts
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    When the following Boosted Content entries exist for the affiliate "agency.gov"
      | url                                        | title                               | description        | status   | publish_start_on | publish_end_on |
      | http://search.gov/releases/2013-05-31.html | Notes for Week Ending May 31, 2013  | multimedia gallery | active   | 2013-08-01       | 2022-01-01     |
      | http://search.gov/releases/2013-06-21.html | Notes for Week Ending June 21, 2013 | spring cleaning    | inactive |                  |                |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text" within the Admin Center content
    And I fill in "query" with "lean"
    And I press "Search"
    Then I should see the following table rows:
      | Notes for Week Ending June 21, 2013 |
    And I should see "Showing matches for 'lean'"
    And I fill in "query" with "lksdjflskdjf"
    And I press "Search"
    Then I should see "No Best Bets found matching 'lksdjflskdjf'"
    When I follow "Reset"
    Then I should be on the agency.gov's Best Bets Texts page

  Scenario: Add/edit/remove best bets texts
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text" within the Admin Center content
    And I follow "Add Best Bets: Text"
    When I fill in the following:
      | URL                  | http://search.gov/releases/2013-06-21.html |
      | Title                | Notes for Week Ending June 21, 2013        |
      | Description          | spring cleaning                            |
      | Keyword 1            | releases                                   |
    And I add the following best bets keywords:
      | keyword |
      | rails   |
      | recalls |
    And I check "Match Keywords Only?"
    And I submit the form by pressing "Add"
    Then I should see "You have added Notes for Week Ending June 21, 2013 to this site"
    And I should see "Status: Active"
    And I should see "Match Keywords Only"
    And I should see the following best bets keywords:
      | keyword  |
      | rails    |
      | recalls  |
      | releases |
    When I follow "Edit"
    And I fill in the following:
      | Title                | Release for Week Ending June 21, 2013 |
      | Keyword 1            |                                       |
    And I uncheck "Match Keywords Only?"
    And I submit the form by pressing "Save"
    Then I should see "You have updated Release for Week Ending June 21, 2013"
    And I should not see "Match Keywords Only"
    And I should not see "rails"
    When I press "Remove" and confirm "Are you sure you wish to remove Release for Week Ending June 21, 2013 from this site?"
    Then I should see "You have removed Release for Week Ending June 21, 2013 from this site"

  Scenario: Bulk upload best bets texts
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text" within the Admin Center content
    And I follow "Bulk Upload"
    And I attach the file "features/support/boosted_content.csv" to "best_bets_text_data_file"
    And I submit the form by pressing "Upload"
    Then I should see "You have added 2 Text Best Bets."
    And I should see "1 Text Best Bet was not uploaded. Please ensure the URLs are properly formatted, including the http:// or https:// prefix."

  Scenario: View Collections
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   |first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John      | Bar       | false                       |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes                            |
      | News | agency1.gov/news/                   |
      | Blog | agency2.gov/blog/,agency3.gov/blog/ |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Collections" within the Admin Center content
    Then I should see the following table rows:
      | Blog |
      | News |
    When I follow "Blog"
    Then I should find "agency2.gov/blog/" in the Collection URL Prefixes modal
    And I should find "agency3.gov/blog/" in the Collection URL Prefixes modal

  Scenario: Add/edit/remove Collection
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Collection" within the Admin Center content
    And I follow "Add Collection"
    When I fill in the following:
      | Name         | News                  |
      | URL Prefix 1 | www.agency1.gov/news/ |
    And I add the following Collection URL Prefixes:
      | url_prefix           |
      | www.agency2.gov/news |
      | 1.agency3.gov     |
    And I submit the form by pressing "Add"
    Then I should see "You have added News to this site"
    When I follow "Edit"
    Then the "Name" field should contain "News"
    And the "URL Prefix 1" field should contain "http://1.agency3.gov/"
    And the "URL Prefix 2" field should contain "http://www.agency1.gov/news/"
    And the "URL Prefix 3" field should contain "http://www.agency2.gov/news/"
    When I fill in the following:
      | Name         | News and Blog |
      | URL Prefix 1 |               |
    And I add the following Collection URL Prefixes:
      | url_prefix       |
      | blog.agency4.gov |
    And I submit the form by pressing "Save"
    Then I should see "You have updated News and Blog"
    When I follow "Edit"
    Then the "URL Prefix 1" field should contain "blog.agency4.gov"
    When I follow "View All"
    Then I should see "News and Blog"
    When I press "Remove" and confirm "Are you sure you wish to remove News and Blog from this site?"
    Then I should see "You have removed News and Blog from this site"

  Scenario: View Routed Queries
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And affiliate "agency.gov" has the following routed queries:
      | description                     | url                                                                            | keywords                        |
      | Free Money                      | https://www.usa.gov/unclaimed-money                                            | free money, unclaimed money     | 
      | Disable Rails Asset Compression | http://www.rrsoft.co/2014/01/13/selectively-disabling-rails-asset-compression/ | disable rails asset compression |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Routed Queries" within the Admin Center content
    Then I should see the following table rows:
      | Free Money |
      | Disable Rails Asset Compression |

  Scenario: Add/Edit/Remove Routed Query
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name    | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar          | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Routed Queries" within the Admin Center content
    And I follow "Add Routed Query"
    When I fill in the following:
      | Routed Query Description | Unclaimed Money                    |
      | Routed Query URL         | https://www.usa.gov/unclaimed-money |
    And I add the following Routed Query Keywords:
      | keyword         |
      | Free Money      |
      | unclaimed money |
    And I submit the form by pressing "Add"
    Then I should see "You have added query routing for the following search terms: 'free money', 'unclaimed money'"
    When I follow "Edit"
    Then the "Keyword or phrase 1" field should contain "free money"
    When I replace the Routed Query Keywords with:
      | keyword         |
      | moar money      |
      |                 |
    And I submit the form by pressing "Save"
    Then I should see "You have updated query routing for the following search term: 'moar money'"
    And I press "Remove" and confirm "Are you sure you wish to remove routing to https://www.usa.gov/unclaimed-money from this site?"
    Then I should see "You have removed query routing for the following search term: 'moar money'"

  Scenario: View domains
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    When the following "site domains" exist for the affiliate agency.gov:
      | domain          |
      | whitehouse.gov  |
      | usa.gov         |
      | gobiernousa.gov |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Domains" within the Admin Center content
    Then I should see the following table rows:
      | gobiernousa.gov |
      | usa.gov         |
      | whitehouse.gov  |

    When I go to the agency.gov's Manage Content page
    Then the "Discover and add the RSS feeds and social media accounts listed on the following page:" field should be empty

  Scenario: Add/edit/remove domains
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "Domains" within the Admin Center content
    And I follow "Add Domain"
    Then I should find "Leave off www to include all subdomains." in "form tooltip"
    When I fill in "Domain" with "usa.gov"
    And I submit the form by pressing "Add"
    Then I should see "You have added usa.gov to this site"
    When I go to the agency.gov's Manage Content page
    Then the "Discover and add the RSS feeds and social media accounts listed on the following page:" field should contain "http://usa.gov"

    When I follow "Domains" within the Admin Center content
    And I follow "Edit"
    And I fill in "Domain" with "gobiernousa.gov"
    And I submit the form by pressing "Save"
    Then I should see "You have updated gobiernousa.gov"
    When I press "Remove" and confirm "Are you sure you wish to remove gobiernousa.gov from this site?"
    Then I should see "You have removed gobiernousa.gov from this site"

  Scenario: View i14y drawers
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | gets_i14y_results | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | true              | false                       |
    And the following "i14y drawers" exist for the affiliate agency.gov:
      | handle      | token         | description           |
      | blog_posts  | token 1       | All our blog posts    |
      | more_posts  | token 2       | More of our stuff     |
    And the following documents exist for the "blog_posts" drawer:
      | title       | path                    | created              | content      |
      | document 1  | http://www.doc1.gov     | 2016-01-01T10:00:00Z | my content   |
      | document 2  | http://www.doc2.dov     | 2015-12-31T10:00:00Z | more content |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "i14y Drawers" within the Admin Center content
    Then I should see the following table rows:
      | Handle      | Description           | Document Total |
      | blog_posts  | All our blog posts    | 2              |
      | more_posts  | More of our stuff     | 0              |
    When I follow "Show" within the first table body row
    Then I should see the secret token for the "blog_posts" drawer
    When I fill in "query" with "more"
    And I press "Search"
    Then I should see "document 2"
    And I should see "12/31/2015"
    And I should not see "document 1"

  Scenario: Add/edit/remove i14y drawers
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | gets_i14y_results | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | true              | false                       |
    And we don't want observers to run during these cucumber scenarios
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Content page
    And I follow "i14y Drawers" within the Admin Center content
    And I follow "Add i14y Drawer"
    And I fill in "Handle" with "another.one"
    And I submit the form by pressing "Add"
    Then I should see "must only contain lowercase letters, numbers, and underscore characters"
    When I fill in "Handle" with "another_one"
    And I fill in "Description" with "This is optional but nice to have"
    And I submit the form by pressing "Add"
    Then I should see the following table rows:
      | Handle      | Description                           | Document Total | Last Document Sent |
      | another_one | This is optional but nice to have     |                |                    |
    And I should see "You have created the another_one i14y drawer."
    When I follow "Edit" within the first table body row
    And I fill in "Description" with "This describes it"
    And I submit the form by pressing "Save"
    Then I should see "You have updated the another_one i14y drawer."
    When I press "Remove" and confirm "Removing this drawer from this site will delete it from the system. Are you sure you want to delete it?"
    Then I should see "You have deleted the another_one i14y drawer and all of its contents."
    And we want observers to run during the rest of these cucumber scenarios

  Scenario: Sharing i14y drawers
    Given the following BingV7 Affiliates exist:
      | display_name | name        | contact_email    | first_name | last_name | gets_i14y_results | use_redesigned_results_page |
      | agency site  | agency.gov  | john@agency.gov  | John Bar   | bar       | true              | false                       |
      | another site | another.gov | jane@another.gov | Jane Bar   | bar       | true              | false                       |
    And I am logged in with email "affiliate_admin@fixtures.org"
    And we don't want observers to run during these cucumber scenarios
    And the following "i14y drawers" exist for the affiliate agency.gov:
      | handle      | token         | description           |
      | blog_posts  | token 1       | All our blog posts    |
    And the "blog_posts" drawer is shared with the "another.gov" affiliate
    When I go to the agency.gov's Manage Content page
    And I follow "i14y Drawers" within the Admin Center content
    And I press "Remove" and confirm "Are you sure you want to remove this drawer from this site?"
    Then I should see "You have removed the blog_posts i14y drawer from this site."
    When I go to the another.gov's Manage Content page
    And I follow "i14y Drawers" within the Admin Center content
    Then I should see "blog_posts"
    And we want observers to run during the rest of these cucumber scenarios

  Scenario: View Filter URLs
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And the following Excluded URLs exist for the site "agency.gov":
      | url                     |
      | http://aff.gov/bad-url1 |
      | http://aff.gov/bad-url2 |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Filter URLs page
    Then I should see the following table rows:
      | aff.gov/bad-url1 |
      | aff.gov/bad-url2 |

  Scenario: Add/remove Filter URL
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Filter URLs page
    And I follow "Add Filter URL"
    And I fill in "URL" with "agency.gov/exclude-me.html"
    And I submit the form by pressing "Add"
    Then I should see "You have added agency.gov/exclude-me.html to this site"
    And I should see the following table rows:
      | agency.gov/exclude-me.html |
    When I press "Remove" and confirm "Are you sure you wish to remove agency.gov/exclude-me.html from this site?"
    Then I should see "You have removed agency.gov/exclude-me.html from this site"

  Scenario: Add/remove Filter Tag
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | gets_i14y_results | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | true              | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Filter Tags page
    And I follow "Add Filter Tag"
    And I fill in "Tag" with "exclude me"
    And I submit the form by pressing "Add"
    Then I should see "You have added the tag exclude me to this site"
    And I should see the following table rows:
      | Tag                | Exclude/Require |
      | exclude me         | Exclude         |
    When I press "Remove" and confirm "Are you sure you wish to remove the tag exclude me from this site?"
    Then I should see "You have removed the tag exclude me from this site"
    When I follow "Add Filter Tag"
    And I fill in "Tag" with "require me"
    And I choose "Require"
    And I submit the form by pressing "Add"
    Then I should see "You have added the tag require me to this site"
    And I should see the following table rows:
      | Tag                | Exclude/Require |
      | require me         | Require         |
    When I follow "Add Filter Tag"
    And I fill in "Tag" with "require me"
    And I choose "Require"
    And I submit the form by pressing "Add"
    Then I should see "Tag has already been taken"

  Scenario: Filtering Supplemental URLs
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And the following IndexedDocuments exist:
      | url                                             | title                | description                     | affiliate  | last_crawled_at | last_crawl_status | source |
      | http://aff.gov/extremelysuperlongurl/space-suit | Space Suit Evolution | description text for space suit | agency.gov | 11/02/2011      | OK                | manual |
      | http://aff.gov/extremelysuperlongurl/rocket     | Rocket Evolution     | description text for rocket     | agency.gov | 11/01/2011      | 404 Not Found     | rss    |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Supplemental URLs page
    And I fill in "query" with "rocket"
    And I press "Search"
    Then I should see the following table rows:
      | URL                                      | Source | Last Crawled | Status |
      | aff.gov/extremelysuperlongurl/rocket     | Feed   | 11/1/2011    | Error  |
    And I should see "Showing matches for 'rocket'"
    And I fill in "query" with "lksdjflskdjf"
    And I press "Search"
    Then I should see "No Supplemental URLs found matching 'lksdjflskdjf'"
    When I follow "Reset"
    Then I should be on the agency.gov's Supplemental URLs page