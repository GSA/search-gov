Feature: Affiliate RSS
  In order to give affiliates the ability to submit a RSS Feed URL
  As an affiliate
  I want to see and manage my RSS Feeds

  Scenario: Visiting my RSS feeds page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "RSS"
    Then I should see the browser page titled "RSS"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > RSS
    And I should see "RSS" in the page header
    And I should see a link to "RSS 2.0 specification" with url for "http://www.rssboard.org/rss-specification"
    And I should see a link to "Atom syndication format" with url for "http://www.atomenabled.org/developers/syndication/"

    When I follow "URLs" in the side note boxes
    Then I should see the browser page titled "URLs & Sitemaps"

  Scenario: Adding RSS feed
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "RSS"
    And I follow "Add new RSS feed"
    And I fill in the following:
      | Name* | Press                                |
      | URL*  | http://www.whitehouse.gov/feed/press |
    And I press "Add"
    Then I should see "RSS feed successfully created."
    And I should see the following table rows:
    | URL               | http://www.whitehouse.gov/feed/press |
    | Name              | Press                                |
    | Last Crawled At   | Pending                              |
    | Last Crawl Status | Pending                              |
