Feature: Affiliate On-Demand Url Indexing Interface
  In order to give affiliates the ability to submit a URL for on-demand indexing
  As an affiliate
  I want to see and manage my Indexed Documents

  Scenario: Visiting my URLs page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following IndexedDocuments exist:
      | title                | description                     | url                                             | affiliate | last_crawled_at | last_crawl_status |
      | Space Suit Evolution | description text for space suit | http://aff.gov/extremelysuperlongurl/space-suit | aff.gov   | 11/02/2011      | OK                |
      | Rocket Evolution     | description text for rocket     | http://aff.gov/extremelysuperlongurl/rocket     | aff.gov   | 11/01/2011      | 404 Not Found     |
    And there are 40 crawled IndexedDocuments for "aff.gov"
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    Then I should see "aff.gov/crawled/36"
    And I should not see "aff.gov/crawled/35"
    And I should not see "aff.gov/space-suit"

    When I follow "View all" in the previously crawled URL list
    Then I should see the browser page titled "Previously Crawled URLs"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs and Sitemaps > Previously Crawled URLs
    And I should see "Previously Crawled URLs" in the page header
    And I should see "aff.gov/crawled/40"
    When I follow "Next"
    Then I should see "aff.gov/crawled/10"
    And I should see the following table rows:
      | URL                | Last Crawled | Status |
      | aff.gov/.../space-suit | 11/02/2011   | OK     |
      | aff.gov/.../rocket     | 11/01/2011   | Error  |

    When there are 40 uncrawled IndexedDocuments for "aff.gov"
    And I go to the "aff site" affiliate page
    And I follow "URLs & Sitemaps"
    And I follow "View all" in the uncrawled URL list
    Then I should see "aff.gov/uncrawled/36"
    And I should not see "aff.gov/uncrawled/10"

  Scenario: Submit a URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    And I follow "Add new URL"
    Then I should see the browser page titled "Add a new URL"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs and Sitemaps > Add a new URL
    And I should see "Add a new URL" in the page header
    When I fill in "URL" with "http://new.url.gov/page.html"
    And I press "Add"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs and Sitemaps > Uncrawled URLs
    And I should see "Successfully added http://new.url.gov/page.html."

    When the url "http://new.url.gov/page.html" has been crawled
    And I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    Then I should see "Uncrawled URLs (0)"
    And I should see "new.url.gov/page.html" in the previously crawled URL list

    When I follow "View all" in the previously crawled URL list
    Then I should see "new.url.gov/page.html"

  Scenario: Remove a URL to be crawled
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following IndexedDocuments exist:
      | url                   | affiliate |
      | http://removeme.mil   | aff.gov   |
      | http://removeme2.mil   | aff.gov  |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    When I press "Delete" in the uncrawled URL list
    Then I should see "Removed http://removeme2.mil"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs & Sitemaps
    When I follow "View all"
    And I should see "removeme.mil"
    When I press "Delete"
    Then I should see "Removed http://removeme.mil"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs and Sitemaps > Uncrawled URLs
    And I should see "Site aff site has no uncrawled URLs"

  Scenario: Submitting a bad URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    And I follow "Add new URL"
    And I fill in "URL" with "notanurl"
    And I press "Add"
    Then I should see the browser page titled "Add a new URL"
    And I should see "Url is invalid"

  Scenario: Bulk-uploading URLs for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    And I follow "Bulk upload"
    Then I should see the browser page titled "Bulk Upload URLs"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs and Sitemaps > Bulk Upload URLs
    And I should see "Bulk Upload URLs" in the page header

    When I attach the file "features/support/superfresh_urls.txt" to "indexed_documents"
    And I press "Upload"
    Then I should see the browser page titled "Uncrawled URLs"
    And I should see "Successfully uploaded 5 urls."

    When I follow "Bulk upload"
    And I attach the file "features/support/too_many_superfresh_urls.txt" to "indexed_documents"
    And I press "Upload"
    Then I should see the browser page titled "Bulk Upload URLs"
    And I should see "Too many URLs in your file."

    When I attach the file "features/support/no_superfresh_urls.txt" to "indexed_documents"
    And I press "Upload"
    Then I should see the browser page titled "Bulk Upload URLs"
    And I should see "No URLs uploaded; please check your file and try again."

    When I attach the file "features/support/invalid_superfresh_file.doc" to "indexed_documents"
    And I press "Upload"
    Then I should see the browser page titled "Bulk Upload URLs"
    And I should see "Invalid file format"

    When I press "Upload"
    Then I should see the browser page titled "Bulk Upload URLs"
    And I should see "Invalid file format"

  Scenario: Deleting a previously crawled url
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following IndexedDocuments exist:
      | url                   | affiliate | last_crawled_at |
      | http://removeme2.mil   | aff.gov   | 2011-11-01      |
      | http://removeme.mil  | aff.gov   | 2011-11-01      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    And I press "Delete"
    Then I should see the browser page titled "URLs & Sitemaps"
    And I should see "Removed http://removeme.mil"
    When I follow "View all"
    Then I should see "removeme2.mil"
    When I press "Delete"
    Then I should see the browser page titled "Previously Crawled URLs"
    And I should see "Removed http://removeme2.mil"

  Scenario: Exporting crawled urls to CSV
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following IndexedDocuments exist:
      | url                   | title   | description       |affiliate | last_crawled_at | last_crawl_status |
      | http://aff.gov/1.html | No. 1   | Number 1          | aff.gov   | 2012-01-19      | OK                |
      | http://aff.gov/2.html | No. 2   | Number 2          | aff.gov   | 2012-01-19      | OK                |
      | http://aff.gov/3.html | No. 3   | Number 3          | aff.gov   |                 |                   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    And I follow "Export to CSV"
    Then I should see "url,title,description,doctype,last_crawled_at,last_crawl_status"
    And I should see "http://aff.gov/1.html,No. 1,Number 1,html,2012-01-19 00:00:00 UTC,OK"
    And I should see "http://aff.gov/2.html,No. 2,Number 2,html,2012-01-19 00:00:00 UTC,OK"
    And I should not see "http://aff.gov/3.html"

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs & Sitemaps"
    And I follow "View all" within ".crawled-url-list"
    And I follow "Export to CSV"
    Then I should see "url,title,description,doctype,last_crawled_at,last_crawl_status"
    And I should see "http://aff.gov/1.html,No. 1,Number 1,html,2012-01-19 00:00:00 UTC,OK"
    And I should see "http://aff.gov/2.html,No. 2,Number 2,html,2012-01-19 00:00:00 UTC,OK"
    And I should not see "http://aff.gov/3.html"
