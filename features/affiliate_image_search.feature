Feature: Affiliate Search
  In order to get government-related images from specific affiliate agencies
  As a site visitor or affiliate admin
  I want to be able to search for images

  Scenario: Affiliate Image Search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I am on bar.gov's search page
    And I fill in "query" with "camels"
    And I press "Search"
    Then I should see "Images"
    And I should not see "Last hour"

    When I follow "Images"
    Then I should see "Everything"
    And I should see at least 8 search results
    And I should not see "Last hour"

    When I follow "Everything"
    Then I should see "Images"
    And I should see at least 8 search results
    And I should not see "Last hour"

  Scenario: Affiliate Image search with RSS feeds
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And affiliate "bar.gov" has the following RSS feeds:
      | name  | url                                  | is_navigable |
      | Press | http://www.whitehouse.gov/feed/press | true         |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | Next news item for the feed  |
    When I am on bar.gov's search page
    And I fill in "query" with "camels"
    And I press "Search"
    Then I should see "Images"
    And I should not see "Last hour"
  
  Scenario: Affiliate Image Search when there are Flickr Photos, and when there are not
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | domains |
      | foo site         | foo.gov          | aff@foo.gov           | John Bar            | usa.gov |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            | usa.gov |   
    And the following FlickrPhotos exist:
      | title     | description             | url_q                         | owner | flickr_id | affiliate_name  |
      | AMERICA   | A picture of our nation | http://www.flickr.com/someurl | 123   | 456       | bar.gov         |
    When I am on bar.gov's image search page
    And I fill in "query" with "government"
    And I press "Search"
    Then I should see "usa.gov"
    And I should not see "flickr.com"
    
    When I am on bar.gov's image search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should not see "usa.gov"
    And I should see "flickr.com"