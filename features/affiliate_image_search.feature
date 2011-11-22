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
  
    When I follow "Images"
    Then I should see "Everything"
  
    When I follow "Everything"
    Then I should see "Images"
    
  Scenario: Enabling/disabling affiliate image search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | 
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            | 
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Content Types"
    Then the "Images" checkbox should be checked
    And I uncheck "Images"
    And I press "Update"
    
    When I am on bar.gov's search page
    And I fill in "query" with "camels"
    And I press "Search"
    Then I should not see "Images"
    
    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Content Types"
    And I check "Images"
    And I press "Update"
    
    When I am on bar.gov's search page
    And I fill in "query" with "camels"
    And I press "Search"
    Then I should see "Images"
    
  Scenario: Affiliate Image search with RSS feeds
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | 
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            | 
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_active |
      | Press         | http://www.whitehouse.gov/feed/press               | true      |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | Next news item for the feed  |
    When I am on bar.gov's search page
    And I fill in "query" with "camels"
    And I press "Search"
    Then I should see "Images"
    And I should see "Last hour"
    
    When I follow "Images"
    Then I should see "Press"
    And I should not see "Last hour"
    