Feature: Bulk Affiliate Styles Upload
  In order to give affiliates the ability to submit a file of URLs for indexing
  As an admin
  I want to upload a file containing Affiliate Styles

  Scenario: Bulk-uploading affiliate styles for on-demand indexing as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the bulk affiliate styles upload admin page
    Then I should see "Bulk Affiliate Styles Upload"
    And I should see "The maximum file size is 4 MB"

    When I attach the file "features/support/bulk_affiliate_styles_upload.csv" to "bulk_upload_affiliate_styles"
    And I press "Upload"
    Then I should be on the bulk affiliate styles upload admin page
    And I should see "Successfully uploaded bulk_affiliate_styles_upload.csv"
    And I should see "The results will be emailed to you."

    When I do not attach a file to "bulk_upload_affiliate_styles"
    And I press "Upload"
    Then I should be on the bulk affiliate styles upload admin page
    And I should see "Please choose a file to upload"
