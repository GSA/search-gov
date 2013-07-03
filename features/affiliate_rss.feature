Feature: Affiliate RSS
  In order to give affiliates the ability to submit a RSS Feed URL
  As an affiliate
  I want to see and manage my RSS Feeds

  Scenario: Visiting my RSS feeds page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | affiliate | url                                                     | name   | last_crawl_status | last_crawled_at |
      | aff.gov   | gdata.youtube.com/feeds/base/videos?author=usgovernment | Videos | 404 Not Found     | 2012-01-01      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "RSS"
    Then I should see the browser page titled "RSS"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > RSS
    And I should see "RSS" in the page header

    When I follow "RSS"
    And I follow "Videos"
    Then I should see the following table rows:
      | URL                                                     | Last Crawled | Status |
      | gdata.youtube.com/feeds/base/videos?author=usgovernment | 1/1/2012     | Error  |

  Scenario: Adding RSS feed
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "RSS"
    And I follow "Add new RSS feed"
    And I fill in the following:
      | Name*          | Videos                                                  |
      | RSS feed URL 0 | gdata.youtube.com/feeds/base/videos?author=usgovernment |
    And I press "Add"
    Then I should see "RSS feed successfully created."
    And I should see the following table rows:
      | Name            | Videos |
      | Feed type       | RSS    |
      | Show as GovBox  | No     |
      | Show in sidebar | No     |
    And I should see the following table rows:
      | URL                                                     | Last Crawled | Status  |
      | gdata.youtube.com/feeds/base/videos?author=usgovernment | Pending      | Pending |
    And I should not see "http://gdata.youtube.com/feeds/base/videos?author=usgovernment"
    When I follow "Add new RSS feed"
    Then I should see the browser page titled "Add a new RSS Feed"
    When I follow "RSS"
    Then I should see a link to "gdata.youtube.com/.../videos?author=usgovernment" with url for "http://gdata.youtube.com/feeds/base/videos?author=usgovernment"
    When I follow "Edit"
    And I fill in the following:
      | RSS feed URL 1 | http://gdata.youtube.com/feeds/base/videos?author=noaa |
    And I press "Update"
    Then I should see "RSS feed successfully updated."
    And I should see the following table rows:
      | Name            | Videos |
      | Feed type       | RSS    |
      | Show as GovBox  | No     |
      | Show in sidebar | No     |
    And I should see the following table rows:
      | URL                                                     | Last Crawled | Status  |
      | gdata.youtube.com/feeds/base/videos?author=noaa         | Pending      | Pending |
      | gdata.youtube.com/feeds/base/videos?author=usgovernment | Pending      | Pending |

  Scenario: Adding MRSS feed
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "RSS"
    And I follow "Add new RSS feed"
    And I fill in the following:
      | Name*          | Videos                                                                         |
      | RSS feed URL 0 | www.flickr.com/services/feeds/photos_public.gne?id=27784370@N05&format=rss_200 |
    And I choose "Media RSS"
    And I press "Add"
    Then I should see "RSS feed successfully created."
    And I should see the following table rows:
      | Name            | Videos    |
      | Feed type       | Media RSS |
      | Show as GovBox  | No        |
      | Show in sidebar | No        |
    And I should see the following table rows:
      | URL                                                                            | Last Crawled | Status  |
      | www.flickr.com/services/feeds/photos_public.gne?id=27784370@N05&format=rss_200 | Pending      | Pending |
    And I should not see "http://www.flickr.com/services/feeds/photos_public.gne?id=27784370@N05&format=rss_200"

  Scenario: Adding duplicate RSS feed
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "RSS"
    And I follow "Add new RSS feed"
    And I fill in the following:
      | Name*          | Recalls                                          |
      | RSS feed URL 0 | http://api.usa.gov/recalls/recent.rss?per_page=1 |
    And I press "Add"
    Then I should see "RSS feed successfully created."
    And I follow "Add new RSS feed"
    And I fill in the following:
      | Name*          | Another Recalls                           |
      | RSS feed URL 0 | api.usa.gov/recalls/recent.rss?per_page=1 |
    And I press "Add"
    Then I should see "RSS feed successfully created."
    And I should see the following table rows:
      | URL                                       | Last Crawled | Status  |
      | api.usa.gov/recalls/recent.rss?per_page=1 | Pending      | Pending |

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
      | Name*          |                                                  |
      | RSS feed URL 0 | http://api.usa.gov/recalls/recent.rss?per_page=1 |
    And I press "Add"
    Then I should see "Name can't be blank"
    When I fill in the following:
      | Name*          | My invalid feed                                   |
      | RSS feed URL 0 | http://api.usa.gov/recalls/recent.json?per_page=1 |
      | RSS feed URL 1 | http:// /recalls                                  |
    And I press "Add"
    Then I should see "Rss feed url does not appear to be a valid RSS feed."
    And I should see "Rss feed url is invalid"

  Scenario: Previewing crawled news items
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | name  | url                                  |
      | Press | http://www.whitehouse.gov/feed/press |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | item First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | item Next news item for the feed  |
    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "RSS"
    And I follow "Preview" in the page content
    Then I should see "First item"
    And I should see "Second item"
    And I go to the "aff site" affiliate page
    And I follow "RSS"
    And I follow "Press"
    And I follow "Preview" in the page content
    Then I should see "First item"
    And I should see "Second item"
