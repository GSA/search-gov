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
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > RSS
    And I should see a link to "RSS 2.0 specification" with url for "http://www.rssboard.org/rss-specification"
    And I should see a link to "Atom syndication format" with url for "http://www.atomenabled.org/developers/syndication/"

    When I follow "URLs" in the side note boxes
    Then I should see the browser page titled "URLs & Sitemaps"
