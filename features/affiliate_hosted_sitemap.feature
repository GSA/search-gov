Feature: Affiliate Hosted Sitemaps
  In order to get site content noticed by commercial search engines
  As an affiliate
  I want to specify one or more domain-specific sitemap URLs hosted by USASearch in my robots.txt files

  Scenario: Visiting my Hosted Sitemaps page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following site domains exist for the affiliate aff.gov:
      | domain                | site_name      |
      | whitehouse.gov        | whitehouse Agency Website |
      | ostp.gov              | ostp Agency Website |
    And the following IndexedDocuments exist:
      | url                                      | affiliate | title            | description         |
      | http://www.whitehouse.gov/our-government/A4C32FAE6F3DB386FC32ED1C4F3024742ED30906 | aff.gov   | Our Government   | white house cabinet |
      | http://www.ostp.gov/fake-page/A4C32FAE6F3DB386FC32ED1C4F3024742ED30906            | aff.gov   | Fake page        | ostp                |
    And the url "http://www.whitehouse.gov/our-government/A4C32FAE6F3DB386FC32ED1C4F3024742ED30906" has been crawled
    And the url "http://www.ostp.gov/fake-page/A4C32FAE6F3DB386FC32ED1C4F3024742ED30906" has been crawled
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Hosted Sitemaps"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Hosted Sitemaps
    And I should see hosted sitemap instructions for "www.whitehouse.gov"
    And I should see hosted sitemap instructions for "www.ostp.gov"