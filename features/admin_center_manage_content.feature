@javascript @vcr
Feature: Manage Content

  Scenario: Viewing Manage Content page after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Manage Content page
    Then I should see a link to "Content" in the active site main navigation
    And I should see a link to "Content Overview" in the active site sub navigation

  Scenario: View best bets graphics
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And the following featured collections exist for the affiliate "agency.gov":
      | title           | title_url                         | status   | publish_start_on | publish_end_on | keywords     |
      | Tornado Warning | http://agency.gov/tornado-warning | active   | 2013-07-01       |                |              |
      | Flood Watches   |                                   | inactive | 2013-08-01       |                |              |
      | Fire Safety     |                                   | active   | 2013-09-01       | 2013-09-30     | burn,lighter |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Graphics" within the Admin Center content
    Then I should see the following table rows:
      | Fire Safety     |
      | Flood Watches   |
      | Tornado Warning |
    And I should see a link to "Tornado Warning" with url for "http://agency.gov/tornado-warning"
    And I should see "Published between 09/01/2013 and 09/30/2013"
    And I should see "Status: Inactive"

  Scenario: Filtering best bets graphics
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And the following featured collections exist for the affiliate "agency.gov":
      | title           | title_url                         | status   | publish_start_on | publish_end_on | keywords     |
      | Tornado Warning | http://agency.gov/tornado-warning | active   | 2013-07-01       |                |              |
      | Flood Watches   |                                   | inactive | 2013-08-01       |                |              |
      | Fire Safety     |                                   | active   | 2013-09-01       | 2013-09-30     | burn,lighter |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Graphics" within the Admin Center content
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
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Graphics" within the Admin Center content
    And I follow "Add Best Bets: Graphics"
    When I fill in the following:
      | Title                 | 2010 Atlantic Hurricane Season          |
      | Title URL             | http://www.nhc.noaa.gov/2010atlan.shtml |
      | Publish End Date      | 07/01/2020                              |
      | Image Alt Text        | hurricane logo                          |
    And I attach the file "features/support/small.jpg" to "Image"
    And I add the following best bets keywords:
      | keyword |
      | storm   |
      | weather |
    And I check "Match Keywords Only?"
    And I add the following best bets graphics links:
      | title              | url                                                   |
      | Hurricane Alex     | http://www.nhc.noaa.gov/pdf/TCR-AL012010_Alex.pdf     |
      | Hurricane Danielle | http://www.nhc.noaa.gov/pdf/TCR-AL062010_Danielle.pdf |
    And I submit the form by pressing "Add"
    Then I should see "You have added 2010 Atlantic Hurricane Season to this site"
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
      | Publish End Date      | 07/01/2020                                            |
      | Image Alt Text        | hurricane logo                                        |
      | Link Title 1          | Hurricane Alex                                        |
      | Link URL 1            | http://www.nhc.noaa.gov/pdf/TCR-AL012010_Alex.pdf     |
      | Link Title 2          | Hurricane Danielle                                    |
      | Link URL 2            | http://www.nhc.noaa.gov/pdf/TCR-AL062010_Danielle.pdf |
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
    Then I should see "Best bets: graphics links title can't be blank"
    Then I should see "Best bets: graphics links url can't be blank"

    When I follow "View All"
    And I press "Remove"
    Then I should see "You have removed 2011 Atlantic Hurricane Season from this site"

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
    And I follow "Best Bets: Text" within the Admin Center content
    Then I should see the following table rows:
      | Notes for Week Ending June 21, 2013 |
      | Notes for Week Ending May 31, 2013  |
    And I should see "Status: Active"
    And I should see "Published between 08/01/2013 and 01/01/2022"

  Scenario: Filtering best bets texts
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    When the following Boosted Content entries exist for the affiliate "agency.gov"
      | url                                                 | title                               | description        | status   | publish_start_on | publish_end_on |
      | http://usasearch.howto.gov/releases/2013-05-31.html | Notes for Week Ending May 31, 2013  | multimedia gallery | active   | 2013-08-01       | 2022-01-01     |
      | http://usasearch.howto.gov/releases/2013-06-21.html | Notes for Week Ending June 21, 2013 | spring cleaning    | inactive |                  |                |
    And I am logged in with email "john@agency.gov" and password "random_string"
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
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text" within the Admin Center content
    And I follow "Add Best Bets: Text"
    When I fill in the following:
      | URL                  | http://usasearch.howto.gov/releases/2013-06-21.html |
      | Title                | Notes for Week Ending June 21, 2013                 |
      | Description          | spring cleaning                                     |
      | Keyword 1            | releases                                            |
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
    When I press "Remove"
    Then I should see "You have removed Release for Week Ending June 21, 2013 from this site"

  Scenario: Bulk upload best bets texts
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Best Bets: Text" within the Admin Center content
    And I follow "Bulk Upload"
    And I attach the file "features/support/boosted_content.csv" to "best_bets_text_data_file"
    And I submit the form by pressing "Upload"
    Then I should see "You have added 2 Text Best Bets."
    And I should see "1 Text Best Bet was not uploaded. Please ensure the URLs are properly formatted, including the http:// or https:// prefix."

  Scenario: View Collections
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes                            |
      | News | agency1.gov/news/                   |
      | Blog | agency2.gov/blog/,agency3.gov/blog/ |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Collections" within the Admin Center content
    Then I should see the following table rows:
      | Blog |
      | News |
    When I follow "Blog"
    Then I should find "agency2.gov/blog/" in the Collection URL Prefixes modal
    And I should find "agency3.gov/blog/" in the Collection URL Prefixes modal

  Scenario: Add/edit/remove Collection
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
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
    And I press "Remove"
    Then I should see "You have removed News and Blog from this site"

  Scenario: View Routed Queries
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And affiliate "agency.gov" has the following routed queries:
      | description                     | url                                                                            | keywords                        |
      | Free Money                      | http://www.usa.gov/unclaimed-money                                             | free money, unclaimed money     | 
      | Disable Rails Asset Compression | http://www.rrsoft.co/2014/01/13/selectively-disabling-rails-asset-compression/ | disable rails asset compression |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Routed Queries" within the Admin Center content
    Then I should see the following table rows:
      | Free Money |
      | Disable Rails Asset Compression |

  Scenario: Add/Edit/Remove Routed Query
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Routed Queries" within the Admin Center content
    And I follow "Add Routed Query"
    When I fill in the following:
      | Routed Query Description | Unclaimed Money                    |
      | Routed Query URL         | http://www.usa.gov/unclaimed-money |
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
    And I press "Remove"
    Then I should see "You have removed query routing for the following search term: 'moar money'"

  Scenario: View domains
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    When the following 'site domains' exist for the affiliate agency.gov:
      | domain          |
      | whitehouse.gov  |
      | usa.gov         |
      | gobiernousa.gov |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Domains" within the Admin Center content
    Then I should see the following table rows:
      | gobiernousa.gov |
      | usa.gov         |
      | whitehouse.gov  |

    When I go to the agency.gov's Manage Content page
    Then the "Discover and add the RSS feeds and social media accounts listed on the following page:" field should be empty

  Scenario: Add/edit/remove domains
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
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
    When I press "Remove"
    Then I should see "You have removed gobiernousa.gov from this site"

  Scenario: View i14y drawers
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | gets_i14y_results |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true              |
    And we don't want observers to run during these cucumber scenarios
    And the following i14y drawers exist for agency.gov:
      | handle      | token         | description           |
      | blog_posts  | token 1       | All our blog posts    |
      | more_posts  | token 2       | More of our stuff     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "i14y Drawers" within the Admin Center content
    Then I should see the following table rows:
      | Handle  | Description    | Document Total | Last Document Sent |
      | blog_posts  | All our blog posts    |    |                    |
      | more_posts  | More of our stuff     |    |                    |
    And we want observers to run during the rest of these cucumber scenarios

  Scenario: Add/edit/remove i14y drawers
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | gets_i14y_results |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true              |
    And we don't want observers to run during these cucumber scenarios
    And the following i14y drawers exist for agency.gov:
      | handle      | token         | description           |
      | blog_posts  | token 1       | All our blog posts    |
      | more_posts  | token 2       | More of our stuff     |
    And I am logged in with email "john@agency.gov" and password "random_string"
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
      | Handle  | Description    | Document Total | Last Document Sent |
      | another_one | This is optional but nice to have     | |        |
      | blog_posts  | All our blog posts                    | |        |
      | more_posts  | More of our stuff                     | |        |
    And I should see "You have created the another_one i14y drawer."
    When I follow "Edit" within the first table body row
    And I fill in "Description" with "This describes it"
    And I submit the form by pressing "Save"
    Then I should see "You have updated the another_one i14y drawer."
    When I press "Remove" within the first table body row
    Then I should see "You have deleted the another_one i14y drawer and all of its contents."
    And we want observers to run during the rest of these cucumber scenarios

  Scenario: View Filter URLs
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And the following Excluded URLs exist for the site "agency.gov":
      | url                     |
      | http://aff.gov/bad-url1 |
      | http://aff.gov/bad-url2 |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Filter URLs page
    Then I should see the following table rows:
      | aff.gov/bad-url1 |
      | aff.gov/bad-url2 |

  Scenario: Add/remove Filter URL
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Filter URLs page
    And I follow "Add Filter URL"
    And I fill in "URL" with "agency.gov/exclude-me.html"
    And I submit the form by pressing "Add"
    Then I should see "You have added agency.gov/exclude-me.html to this site"
    And I should see the following table rows:
      | agency.gov/exclude-me.html |
    When I press "Remove"
    Then I should see "You have removed agency.gov/exclude-me.html from this site"

  Scenario: Add/remove Filter Tag
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | gets_i14y_results |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true              |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Filter Tags page
    And I follow "Add Filter Tag"
    And I fill in "Tag" with "exclude me"
    And I submit the form by pressing "Add"
    Then I should see "You have added the tag exclude me to this site"
    And I should see the following table rows:
      | Tag                | Exclude/Require |
      | exclude me         | Exclude         |
    When I press "Remove"
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
    And I follow "Flickr" within the Admin Center content
    Then I should see the following table rows:
      | www.flickr.com/groups/usagov/     |
      | www.flickr.com/photos/whitehouse/ |

  Scenario: Add/remove Flickr URL
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Flickr" within the Admin Center content
    And I follow "Add Flickr URL"
    When I fill in "Flickr URL" with "www.flickr.com/groups/usagov/"
    And I submit the form by pressing "Add"
    Then I should see "You have added www.flickr.com/groups/usagov/ to this site"
    When I press "Remove"
    Then I should see "You have removed www.flickr.com/groups/usagov/ from this site"

  Scenario: View Instagram usernames
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    When the following Instagram usernames exist for the site "agency.gov":
      | username   |
      | whitehouse |
      | dg_search  |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Instagram" within the Admin Center content
    Then I should see the following table rows:
      | dg_search  |
      | whitehouse |

  Scenario: Add/remove Instagram usernames
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Instagram" within the Admin Center content
    And I follow "Add Instagram Username"
    When I fill in "Instagram Username" with "dg_search"
    And I submit the form by pressing "Add"
    Then I should see "You have added dg_search to this site"
    And I should see a link to "dg_search" with url for "http://instagram.com/dg_search"

    When I follow "Add Instagram Username"
    When I fill in "Instagram Username" with "dg_search"
    And I submit the form by pressing "Add"
    Then I should see "You have already added dg_search to this site"
    When I fill in "Instagram Username" with "dg_search101"
    And I submit the form by pressing "Add"
    Then I should see "Username is not found"

    When I follow "View All"
    And I press "Remove"
    Then I should see "You have removed dg_search from this site"

    #'mctgsa' is a sandbox account. Once https://www.pivotaltracker.com/story/show/121072675
    #is resolved, we should change that to another standard Instagram username, i.e. 'whitehouse'
    When I follow "Add Instagram Username"
    When I fill in "Instagram Username" with "http://instagram.com/mctgsa"
    And I submit the form by pressing "Add"
    Then I should see "You have added mctgsa to this site"
    And I should see a link to "mctgsa" with url for "http://instagram.com/mctgsa"

    When I follow "Add Instagram Username"
    When I fill in "Instagram Username" with "http://instagram.com/thisisaninstagramprofilethatshouldnotexist31415/"
    And I submit the form by pressing "Add"
    Then I should see "Username is not found"

  Scenario: View RSS
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And affiliate "agency.gov" has the following RSS feeds:
      | name   | url                                                     | last_crawl_status | last_crawled_at | show_only_media_content | is_managed |
      | News   | usasearch.howto.gov/all.atom                            | OK                | 2013-01-01      |                         |            |
      | Videos | gdata.youtube.com/feeds/base/videos?author=usgovernment | Pending           | Pending         |                         | true       |
      | Images | www.flickr.com/photos_public.gne?id=27784370@N05        | 404 Not Found     | 2013-07-01      | true                    |            |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "RSS" within the Admin Center content
    Then I should see the following table rows:
      | Images (Media RSS) |
      | News               |
      | Videos (YouTube)   |
    And I should find "Images" in the first table body error row
    And I should find "News" in the first table body success row
    And I should find "Videos" in the first table body warning row

    When I follow "Images"
    Then I should find "www.flickr.com/photos_public.gne?id=27784370@N05" in the RSS URLs modal

    When I go to the agency.gov's "Images" RSS feed page
    And I follow "Error"
    Then I should find "404 Not Found" in the RSS URL last crawl status error message

  Scenario: Add/edit/remove RSS Feed
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "RSS" within the Admin Center content
    And I follow "Add RSS Feed"
    When I fill in the following:
      | Name  | Recalls                                                                          |
      | URL 1 | http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/HealthFraud/rss.xml |
    And I choose "RSS"
    And I add the following RSS Feed URLs:
      | url                                                                                |
      | http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/FoodAllergies/rss.xml |
    And I submit the form by pressing "Add"
    Then I should see "You have added Recalls to this site"
    When I follow "Edit"
    Then the "Name" field should contain "Recalls"
    And the "URL 1" field should contain "http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/FoodAllergies/rss.xml"
    And the "URL 2" field should contain "http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/HealthFraud/rss.xml"
    When I fill in "Name" with "Food, Safety and Pet Health Recalls"
    And I add the following RSS Feed URLs:
      | url                                                                            |
      | http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/PetHealth/rss.xml |
    And I submit the form by pressing "Save"
    Then I should see "You have updated Food, Safety and Pet Health Recalls"
    When I press "Remove"
    Then I should see "You have removed Food, Safety and Pet Health Recalls from this site"

  Scenario: Edit/remove Supplemental Feed
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Supplemental URLs page
    And I access the "Advanced" dropdown menu
    And I follow "Supplemental Feed"
    And I fill in "URL" with ""
    And I submit the form by pressing "Save"
    Then I should see "URL can't be blank"
    When I fill in the following:
      | URL | usasearch.howto.gov/all.atom |
    And I submit the form by pressing "Save"
    Then I should see "You have updated your supplemental feed for this site"
    And the "URL" field should contain "http://usasearch.howto.gov/all.atom"
    And I should see "Last Crawled Pending"
    And I should see "Status Pending"
    When I press "Remove"
    Then I should see "You have removed your supplemental feed from this site"

  Scenario: View Supplemental URLs
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And the following IndexedDocuments exist:
      | url                                             | title                | description                     | affiliate  | last_crawled_at | last_crawl_status | source |
      | http://aff.gov/extremelysuperlongurl/space-suit | Space Suit Evolution | description text for space suit | agency.gov | 11/02/2011      | OK                | manual |
      | http://aff.gov/extremelysuperlongurl/rocket     | Rocket Evolution     | description text for rocket     | agency.gov | 11/01/2011      | 404 Not Found     | rss    |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Supplemental URLs page
    Then I should see the following table rows:
      | URL                                      | Source | Last Crawled | Status |
      | aff.gov/extremelysuperlongurl/rocket     | Feed   | 11/1/2011    | Error  |
      | aff.gov/extremelysuperlongurl/space-suit | Manual | 11/2/2011    | OK     |
    When I follow "Error"
    Then I should find "404 Not Found" in the Supplemental URL last crawl status error message

  Scenario: Filtering Supplemental URLs
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And the following IndexedDocuments exist:
      | url                                             | title                | description                     | affiliate  | last_crawled_at | last_crawl_status | source |
      | http://aff.gov/extremelysuperlongurl/space-suit | Space Suit Evolution | description text for space suit | agency.gov | 11/02/2011      | OK                | manual |
      | http://aff.gov/extremelysuperlongurl/rocket     | Rocket Evolution     | description text for rocket     | agency.gov | 11/01/2011      | 404 Not Found     | rss    |
    And I am logged in with email "john@agency.gov" and password "random_string"
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

  Scenario: Add/edit/remove Supplemental URL
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Supplemental URLs page
    And I follow "Add Supplemental URL"
    And I fill in the following:
      | URL         | usasearch.howto.gov/developer/jobs.html             |
      | Title       | Jobs API                                            |
      | Description | Helping job seekers land a job with the government. |
    And I submit the form by pressing "Add"
    Then I should see "You have added usasearch.howto.gov/developer/jobs.html to this site"
    And I should see the following table rows:
      | URL                                     | Source |
      | usasearch.howto.gov/developer/jobs.html | Manual |
    And I should see the following table rows:
      | Status     |
      | Summarized |
    When I press "Remove"
    Then I should see "You have removed usasearch.howto.gov/developer/jobs.html from this site"

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
    And I follow "Twitter" within the Admin Center content
    Then I should see the following table rows:
      | @usagov    |
      | @USASearch |

  Scenario: Add/remove Twitter Handle
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Twitter" within the Admin Center content
    And I follow "Add Twitter Handle"
    When I fill in "Twitter Handle" with "dg_search"
    And I check "Show tweets from my lists"
    And I submit the form by pressing "Add"
    Then I should see "You have added @DG_Search to this site"
    And I should see a link to "@DG_Search" with url for "https://twitter.com/DG_Search"
    And I should see "@DG_Search (show lists)"
    When I press "Remove"
    Then I should see "You have removed @DG_Search from this site"
    When I follow "Add Twitter Handle"
    When I fill in "Twitter Handle" with "usasearch101"
    And I submit the form by pressing "Add"
    Then I should see "Screen name is not found"

  Scenario: View YouTube Channels
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And the following YouTube channels exist for the site "agency.gov":
      | title        | channel_id              |
      | USGovernment | usgovernment_channel_id |
      | GobiernoUSA  | gobiernousa_channel_id  |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "YouTube" within the Admin Center content
    Then I should see the following table rows:
      | GobiernoUSA  |
      | USGovernment |

  Scenario: Add/remove YouTube Channel
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "YouTube" within the Admin Center content
    And I follow "Add YouTube Channel"
    When I fill in "YouTube Channel URL" with " youtube.com/USGovernment "
    And I submit the form by pressing "Add"
    Then I should see "You have added usgovernment channel to this site"
    And I should see a link to "usgovernment" with url for "https://www.youtube.com/channel/UCWjkPmmzCdPZEKtGciLf1mg"

    When I follow "Display"
    Then the "Is video govbox enabled" should be switched on

    When I follow "Content"
    And I follow "RSS" within the Admin Center content
    And I follow "Videos"
    Then I should see "www.youtube.com/channel/UCWjkPmmzCdPZEKtGciLf1mg"

    When I go to the agency.gov's Manage Content page
    And I follow "YouTube" within the Admin Center content
    And I press "Remove"
    Then I should see "You have removed usgovernment channel from this site"
    When I follow "Add YouTube Channel"
    When I fill in "YouTube Channel URL" with "http://www.youtube.com/usasearch"
    And I submit the form by pressing "Add"
    Then I should see "Url is not found"

    When I follow "Display"
    Then I should not see "Videos"
