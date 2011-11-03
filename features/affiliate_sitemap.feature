Feature: Affiliate Sitemaps
  In order to give affiliates the ability to submit a Sitemap URL
  As an affiliate
  I want to see and manage my Sitemaps

  Scenario: Visiting my Sitemaps page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Sitemaps"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Sitemaps
    And I should see "Site aff site has no sitemaps"
    And I should see a link to "http://sitemaps.org" with url for "http://sitemaps.org"
    
    When I fill in "URL*" with "http://www.dol.gov/TMP/public.xml"
    And I press "Add"
    Then I should see "Sitemap successfully added."
    And I should see "Displaying 1 sitemap"
    And I should see "http://www.dol.gov/TMP/public.xml"
    
    When I press "Delete"
    Then I should see "Sitemap successfully deleted."
    And I should not see "http://www.dol.gov/TMP/public.xml"
    
    When I fill in "URL*" with "www.dol.gov/TMP/public.xml"
    And I press "Add"
    Then I should see "Url is invalid"
    
    