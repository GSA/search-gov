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
    When I follow "Boosted Content" within ".right-sidebar"
    Then I should see "aff site > Boosted Content"

  Scenario: Submit a URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page
    And I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Add to Bing"
    And I should see "Add to Bing"
    When I fill in "Single URL" with "http://new.url.com"
    And I press "Submit"
    Then I should be on the affiliate superfresh page
    And I should see "Successfully added http://new.url.com."
    And I should see "Uncrawled URLs (1)"
    And I should see "http://new.url.com" within ".uncrawled-url"
  
    When the user agent is the MSNbot
    And I call the superfresh feed
    Then I should see "http://new.url.com"
    
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should see "Uncrawled URLs (0)"
    And I should see "http://new.url.com" within ".crawled-url"
    
  Scenario: Remove a URL to be crawled
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following SuperfreshUrls exist:
      | url                   | affiliate |
      | http://removeme.com   | aff.gov   |        
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page
    When I press "Remove URL"
    Then I should be on the affiliate superfresh page
    And I should see "Removed http://removeme.com"

  Scenario: Submitting a bad URL for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page
    And I should see "Add to Bing"
    When I fill in "Single URL" with ""
    And I press "Submit"
    Then I should be on the affiliate superfresh page
    And I should see "There was an error adding the URL to be refreshed."
    
  Scenario: Bulk-uploading URLs for on-demand indexing
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page
    And I should see "Bulk Upload"
    
    When I attach the file "features/support/superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the affiliate superfresh page
    And I should see "Successfully uploaded 5 urls."
    
    When I attach the file "features/support/too_many_superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the affiliate superfresh page
    And I should see "Too many URLs in your file."
    
    When I attach the file "features/support/no_superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the affiliate superfresh page
    And I should see "No urls uploaded; please check your file and try again."
    
    When I attach the file "features/support/invalid_superfresh_file.doc" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the affiliate superfresh page
    And I should see "Invalid file format"