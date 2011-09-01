Feature: Affiliate Superfresh Interface
  In order to give affiliates the ability to submit a URL for on-demand indexing by Bing
  As an affiliate
  I want to see and manage my Superfresh URLs

  Scenario: Visiting my superfresh page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should see "Learn more about our Add to Bing™ feature by going to our new section in the Help Desk"
    And I should see "Another Way to Highlight Content"

    When I follow "boosted content"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Boosted Contents

    When I follow "Add to Bing"
    And I follow "Boosted Content" in the callout boxes
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Boosted Contents

  Scenario: Submit a URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Add to Bing
    And I should see "Add to Bing"
    When I fill in "Single URL" with "http://new.url.gov"
    And I press "Submit"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Successfully added http://new.url.gov."
    And I should see "Uncrawled URLs (1)"
    And I should see "http://new.url.gov" within ".uncrawled-url"

    When the MSNbot visits the superfresh feed
    Then I should see "http://new.url.gov"

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should see "Uncrawled URLs (0)"
    And I should see "http://new.url.gov" within ".crawled-url"

  Scenario: Remove a URL to be crawled
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following SuperfreshUrls exist:
      | url                   | affiliate |
      | http://removeme.mil   | aff.gov   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page for "aff.gov"
    When I follow "Remove URL"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Removed http://removeme.mil"

  Scenario: Submitting a bad URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Add to Bing"
    When I fill in "Single URL" with "notanurl.html"
    And I press "Submit"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Url is invalid"

  Scenario: Bulk-uploading URLs for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Bulk Upload"

    When I attach the file "features/support/superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Successfully uploaded 5 urls."

    When I attach the file "features/support/too_many_superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Too many URLs in your file."

    When I attach the file "features/support/no_superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "No urls uploaded; please check your file and try again."

    When I attach the file "features/support/invalid_superfresh_file.doc" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Invalid file format"

    When I press "Upload"
    Then I should be on the affiliate superfresh page for "aff.gov"
    And I should see "Invalid file format"

  Scenario: Bulk-uploading URLs for on-demand indexing as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the superfresh bulk upload admin page
    Then I should see "Superfresh Bulk Upload"

    When I attach the file "features/support/superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the superfresh bulk upload admin page
    And I should see "Successfully uploaded 5 urls."

    When I attach the file "features/support/too_many_superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the superfresh bulk upload admin page
    And I should see "Successfully uploaded 101 urls."

    When I attach the file "features/support/no_superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the superfresh bulk upload admin page
    And I should see "No urls uploaded; please check your file and try again."

    When I attach the file "features/support/invalid_superfresh_file.doc" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the superfresh bulk upload admin page
    And I should see "Invalid file format"

    When I press "Upload"
    Then I should be on the superfresh bulk upload admin page
    And I should see "Invalid file format"