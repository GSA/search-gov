Feature: Manage Content

  Scenario: Viewing Manage Content page after logging in
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Manage Content page
    Then I should see "Admin Center"
    Then I should see a link to "Manage Content" in the active site main navigation
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
    And I add the following best bets text keywords:
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

  @javascript
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
    And I follow "Collections"
    Then I should see the following table rows:
      | Blog |
      | News |
    When I follow "Blog"
    Then I should find "agency2.gov/blog/" in the Collection URL Prefixes modal
    And I should find "agency3.gov/blog/" in the Collection URL Prefixes modal

  @javascript
  Scenario: Add/edit/remove Collection
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "Collection"
    And I follow "Add Collection"
    When I fill in the following:
      | Name         | News                  |
      | URL Prefix 1 | www.agency1.gov/news/ |
    And I add the following Collection URL Prefixes:
      | url_prefix           |
      | www.agency2.gov/news |
      | news.agency3.gov     |
    And I press "Add"
    Then I should see "You have added News to this site"
    When I follow "Edit"
    Then the "Name" field should contain "News"
    And the "URL Prefix 1" field should contain "http://news.agency3.gov/"
    And the "URL Prefix 2" field should contain "http://www.agency1.gov/news/"
    And the "URL Prefix 3" field should contain "http://www.agency2.gov/news/"
    When I fill in "Name" with "News and Blog"
    And I add the following Collection URL Prefixes:
      | url_prefix       |
      | blog.agency4.gov |
    And I press "Save"
    Then I should see "You have updated News and Blog"
    When I press "Remove"
    Then I should see "You have removed News and Blog from this site"

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

  @javascript
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
    And I follow "RSS"
    Then I should see the following table rows:
      | Images (Media RSS) |
      | News               |
      | Videos (YouTube)   |
    When I follow "Images"
    Then I should find "www.flickr.com/photos_public.gne?id=27784370@N05" in the RSS URLs modal
    When I follow "Error"
    Then I should find "404 Not Found" in the RSS URL error section

  @javascript
  Scenario: Add/edit/remove RSS Feed
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Content page
    And I follow "RSS"
    And I follow "Add RSS Feed"
    When I fill in the following:
      | Name      | Recalls                                                    |
      | URL 1     | http://www.cpsc.gov/en/Newsroom/CPSC-RSS-Feed/Recalls-RSS/ |
    And I choose "RSS"
    And I add the following RSS Feed URLs:
      | url                                                                                |
      | http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/FoodAllergies/rss.xml |
    And I press "Add"
    Then I should see "You have added Recalls to this site"
    When I follow "Edit"
    Then the "Name" field should contain "Recalls"
    And the "URL 1" field should contain "http://www.cpsc.gov/en/Newsroom/CPSC-RSS-Feed/Recalls-RSS/"
    And the "URL 2" field should contain "http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/FoodAllergies/rss.xml"
    When I fill in "Name" with "Food, Safety and Pet Health Recalls"
    And I add the following RSS Feed URLs:
      | url                                                                            |
      | http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/PetHealth/rss.xml |
    And I press "Save"
    Then I should see "You have updated Food, Safety and Pet Health Recalls"
    When I press "Remove"
    Then I should see "You have removed Food, Safety and Pet Health Recalls from this site"

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
    And I should see a link to "@USASearch" with url for "https://twitter.com/USASearch"
    And I should see "@USASearch (show lists)"
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
