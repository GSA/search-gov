Feature: Admin Superfresh Interface
  In order to give affiliates the ability to submit a URL for on-demand indexing by Bing
  As an admin
  I want to see and manage my Superfresh Urls

  Scenario: Bulk-uploading URLs for on-demand indexing as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the superfresh bulk upload admin page
    Then I should see "Superfresh Bulk Upload"

    When I attach the file "features/support/superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the superfresh bulk upload admin page
    And I should see "Successfully uploaded 5 urls."

    When I attach the file "features/support/too_many_superfresh_urls.txt" to "superfresh_urls"
    And I press "Upload"
    Then I should be on the superfresh bulk upload admin page
    And I should see "Successfully uploaded 10001 urls."

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
