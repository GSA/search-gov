Feature: Affiliate On-Demand Url Indexing Interface
  In order to give affiliates the ability to submit a URL for on-demand indexing
  As an affiliate
  I want to see and manage my Indexed Documents

  Scenario: Visiting my URLs page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following IndexedDocuments exist:
      | title                | description                     | url                       | affiliate | last_crawled_at | last_crawl_status |
      | Space Suit Evolution | description text for space suit | http://aff.gov/space-suit | aff.gov   | 11/02/2011      | OK                |
      | Rocket Evolution     | description text for rocket     | http://aff.gov/rocket     | aff.gov   | 11/01/2011      | 404 Not Found     |
    And there are 40 crawled IndexedDocuments for "aff.gov"
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > URLs
    And I should see "aff.gov/.../36"
    And I should not see "aff.gov/.../35"
    And I should not see "aff.gov/space-suit"

    When I follow "View all"
    Then I should see the browser page titled "Previously Crawled URLs"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > URLs > Previously Crawled URLs
    And I should see "Previously Crawled URLs" in the page header
    And I should see "aff.gov/crawled/40"
    When I follow "Next"
    Then I should see "aff.gov/crawled/10"
    And I should see the following table rows:
      | URL                | Last Crawled | Status |
      | aff.gov/space-suit | 11/02/2011   | OK     |
      | aff.gov/rocket     | 11/01/2011   | Error  |

  Scenario: Submit a URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > URLs
    When I fill in "Single URL" with "http://new.url.gov"
    And I press "Submit"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "Successfully added http://new.url.gov."

    When the url "http://new.url.gov" has been crawled
    And I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    Then I should see "Uncrawled URLs (0)"
    And I should see "http://new.url.gov" in the previously crawled URL list

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
    And I follow "URLs"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    When I press "Delete"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "Removed http://removeme.mil"
    When I follow "View all"
    Then I should see "http://removeme2.mil"
    When I press "Delete"
    Then I should be on the affiliate uncrawled on-demand urls page for "aff.gov"
    And I should see "Removed http://removeme2.mil"    

  Scenario: Submitting a bad URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    And I fill in "Single URL" with "notanurl"
    And I press "Submit"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "Url is invalid"

  Scenario: Bulk-uploading URLs for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "URLs"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "Bulk Upload"

    When I attach the file "features/support/superfresh_urls.txt" to "indexed_documents"
    And I press "Upload"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "Successfully uploaded 5 urls."

    When I attach the file "features/support/too_many_superfresh_urls.txt" to "indexed_documents"
    And I press "Upload"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "Too many URLs in your file."

    When I attach the file "features/support/no_superfresh_urls.txt" to "indexed_documents"
    And I press "Upload"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "No urls uploaded; please check your file and try again."

    When I attach the file "features/support/invalid_superfresh_file.doc" to "indexed_documents"
    And I press "Upload"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "Invalid file format"

    When I press "Upload"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
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
    And I follow "URLs"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    When I press "Delete"
    Then I should be on the affiliate on-demand urls page for "aff.gov"
    And I should see "Removed http://removeme.mil"
    When I follow "View all"
    Then I should see "http://removeme2.mil"
    When I press "Delete"
    Then I should be on the affiliate crawled on-demand urls page for "aff.gov"
    And I should see "Removed http://removeme2.mil"
    