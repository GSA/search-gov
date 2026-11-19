@javascript
Feature: Manage Content

  Scenario: Viewing Manage Content page after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Manage Content page
    Then I should see a link to "Content" in the active site main navigation
    And I should see a link to "Content Overview" in the active site sub navigation

  Scenario: View best bets texts
    Given the following OpenSearch Affiliates exist:
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
    Given the following OpenSearch Affiliates exist:
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
    Given the following OpenSearch Affiliates exist:
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
    Given the following OpenSearch Affiliates exist:
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
    Given the following OpenSearch Affiliates exist:
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
    Given the following OpenSearch Affiliates exist:
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
    Given the following OpenSearch Affiliates exist:
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
    Given the following OpenSearch Affiliates exist:
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
    Given the following OpenSearch Affiliates exist:
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

  Scenario: Add/edit/remove domains
    Given the following OpenSearch Affiliates exist:
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
    And I follow "Domains" within the Admin Center content
    And I follow "Edit"
    And I fill in "Domain" with "gobiernousa.gov"
    And I submit the form by pressing "Save"
    Then I should see "You have updated gobiernousa.gov"
    When I press "Remove" and confirm "Are you sure you wish to remove gobiernousa.gov from this site?"
    Then I should see "You have removed gobiernousa.gov from this site"

  Scenario: Filtering Supplemental URLs
    Given the following OpenSearch Affiliates exist:
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