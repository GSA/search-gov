Feature: Affiliate On-Demand Url Indexing Interface
  In order to give affiliates the ability to submit a RSS Feed URL or individual document for on-demand indexing
  As an affiliate
  I want to see and manage my Indexed Documents and the RSS feed that lists them

  Scenario: Visiting my URLs page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following IndexedDocuments exist:
      | title                | description                     | url                                             | affiliate | last_crawled_at | last_crawl_status |
      | Space Suit Evolution | description text for space suit | http://aff.gov/extremelysuperlongurl/space-suit | aff.gov   | 11/02/2011      | OK                |
      | Rocket Evolution     | description text for rocket     | http://aff.gov/extremelysuperlongurl/rocket     | aff.gov   | 11/01/2011      | 404 Not Found     |
    And there are 40 crawled IndexedDocuments for "aff.gov"
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    Then I should see "aff.gov/crawled/36"
    And I should not see "aff.gov/crawled/35"
    And I should not see "aff.gov/space-suit"

    When I follow "View all" in the previously crawled URL list
    Then I should see the browser page titled "Previously Crawled URLs"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs > Previously Crawled URLs
    And I should see "Previously Crawled URLs" in the page header
    And I should see "aff.gov/crawled/40"
    When I follow "Next"
    Then I should see "aff.gov/crawled/10"
    And I should see the following table rows:
      | URL                    | Last Crawled | Status |
      | aff.gov/.../space-suit | 11/2/2011    | OK     |
      | aff.gov/.../rocket     | 11/1/2011    | Error  |

    When there are 40 uncrawled IndexedDocuments for "aff.gov"
    And I go to the "aff site" affiliate page
    And I follow "URLs"
    And I follow "View all" in the uncrawled URL list
    Then I should see "aff.gov/uncrawled/20"

  Scenario: Submit a RSS Feed URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    And I fill in "site_feed_url_rss_url" with "http://new.aff.gov/page.html"
    And I press "Submit"
    Then I should see "RSS site feed URL added. It will be fetched soon for indexing."
    And the "URL" field should contain "http://new.aff.gov/page.html"
    When I fill in "site_feed_url_rss_url" with ""
    And I press "Submit"
    Then I should see "Problem updating RSS site feed: URL can't be blank"
    When I fill in "site_feed_url_rss_url" with "new.aff.gov/updated.html"
    And I press "Submit"
    Then I should see "RSS site feed URL updated. It will be fetched soon for indexing."
    And the "URL" field should contain "http://new.aff.gov/updated.html"
    When I press "Delete"
    Then I should see "Removed site feed URL http://new.aff.gov/updated.html and all indexed documents."
    When I press "Submit"
    Then I should see "Problem creating RSS site feed: URL can't be blank"

  Scenario: Submit an individual URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    And I follow "Add new URL"
    Then I should see the browser page titled "Add a new URL"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs > Add a new URL
    And I should see "Add a new URL" in the page header
    When I fill in "URL" with "http://new.aff.gov/page.html"
    And I fill in "Title" with "Some title"
    And I fill in "Description" with "Some description"
    And I press "Add"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs > Uncrawled URLs
    And I should see "Successfully added http://new.aff.gov/page.html."

    When the url "http://new.aff.gov/page.html" has been crawled
    And I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    Then I should see "Uncrawled URLs (0)"
    And I should see "new.aff.gov/page.html" in the previously crawled URL list

    When I follow "View all" in the previously crawled URL list
    Then I should see "new.aff.gov/page.html"

  Scenario: Remove a crawled URL
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following IndexedDocuments exist:
      | url                  | affiliate | source | title       | description   |
      | http://aff.gov/1.pdf | aff.gov   | manual | some title  | describe me   |
    And the url "http://aff.gov/1.pdf" has been crawled
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    Then I should see "aff.gov/1.pdf" in the previously crawled URL list

    When I press "Delete" in the previously crawled URL list
    Then I should see "Removed http://aff.gov/1.pdf"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs

  Scenario: Exporting crawled urls to CSV
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following IndexedDocuments exist:
      | url                   | title | description | affiliate | last_crawled_at | last_crawl_status | doctype |
      | http://aff.gov/1.html | No. 1 | Number 1    | aff.gov   | 2012-01-19      | OK                | html    |
      | http://aff.gov/2.html | No. 2 | Number 2    | aff.gov   | 2012-01-19      | OK                | html    |
      | http://aff.gov/3.html | No. 3 | Number 3    | aff.gov   |                 |                   | html    |
    And there are 40 crawled IndexedDocuments for "aff.gov"
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    And I follow "Export to CSV"
    Then I should see "url,title,description,doctype,last_crawled_at,last_crawl_status"
    And I should see "http://aff.gov/1.html,No. 1,Number 1,html,2012-01-19 00:00:00 UTC,OK"
    And I should see "http://aff.gov/2.html,No. 2,Number 2,html,2012-01-19 00:00:00 UTC,OK"
    And I should see "http://aff.gov/crawled/1,crawled document 1,crawled document description 1,"
    And I should see "http://aff.gov/crawled/40,crawled document 40,crawled document description 40,"
    And I should not see "http://aff.gov/3.html"

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    And I follow "View all" within ".crawled-url-list"
    And I follow "Export to CSV"
    Then I should see "url,title,description,doctype,last_crawled_at,last_crawl_status"
    And I should see "http://aff.gov/1.html,No. 1,Number 1,html,2012-01-19 00:00:00 UTC,OK"
    And I should see "http://aff.gov/2.html,No. 2,Number 2,html,2012-01-19 00:00:00 UTC,OK"
    And I should see "http://aff.gov/crawled/1,crawled document 1,crawled document description 1,"
    And I should see "http://aff.gov/crawled/40,crawled document 40,crawled document description 40,"
    And I should not see "http://aff.gov/3.html"
