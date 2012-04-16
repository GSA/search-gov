Feature: Affiliate RSS
  In order to give affiliates the ability to submit a RSS Feed URL
  As an affiliate
  I want to see and manage my RSS Feeds

  Scenario: Visiting my RSS feeds page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | affiliate | url                     | name | last_crawl_status | last_crawled_at |
      | aff.gov   | usasearch.howto.gov/rss | Blog | 404 Not Found     | 2012-01-01      |
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

    When I follow "RSS"
    And I follow "Blog"
    Then I should see the following table rows:
      | URL                     | Last Crawled | Status |
      | usasearch.howto.gov/rss | 01/01/2012   | Error  |

  Scenario: Adding RSS feed
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "RSS"
    And I follow "Add new RSS feed"
    And I fill in the following:
      | Name*          | Press                   |
      | RSS feed URL 0 | usasearch.howto.gov/rss |
    And I press "Add"
    Then I should see "RSS feed successfully created."
    And I should see the following table rows:
      | Name            | Press |
      | Show as GovBox  | No    |
      | Show in sidebar | No    |
    And I should see the following table rows:
      | URL                     | Last Crawled | Status  |
      | usasearch.howto.gov/rss | Pending      | Pending |
    And I should not see "http://usasearch.howto.gov/rss"
    When I follow "Add new RSS feed"
    Then I should see the browser page titled "Add a new RSS Feed"
    When I follow "RSS"
    Then I should see a link to "usasearch.howto.gov/rss" with url for "http://usasearch.howto.gov/rss"
    When I follow "Edit"
    And I fill in the following:
      | RSS feed URL 1 | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usgovernment&orderby=published |
    And I press "Update"
    Then I should see "RSS feed successfully updated."
    Then I should see the following table rows:
      | URL                                                                               | Last Crawled | Status  |
      | gdata.youtube.com/feeds/base/videos?alt=rss&author=usgovernment&orderby=published | Pending      | Pending |
      | usasearch.howto.gov/rss                                                           | Pending      | Pending |

  Scenario: Validating RSS feed input
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "RSS"
    And I follow "Add new RSS feed"
    And I fill in the following:
      | Name* | Press |
    And I press "Add"
    Then I should see "RSS feed must have 1 or more URLs"
    And I fill in the following:
      | Name*          |                                |
      | RSS feed URL 0 | http://usasearch.howto.gov/rss |
    And I press "Add"
    Then I should see "Name can't be blank"

