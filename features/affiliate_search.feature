Feature: Affiliate Search
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information

  Scenario: Search with a blank query on an affiliate page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    When I am on bar.gov's search page
    And I press "Search"
    Then I should see "Please enter search term(s)"

  Scenario: Searching with active RSS feeds
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And affiliate "bar.gov" has the following RSS feeds:
    | name    | url                                                | is_active  |
    | Blog    | http://www.whitehouse.gov/feed/blog                | true       |
    | Press   | http://www.whitehouse.gov/feed/media/photo-gallery | true       |
    | Hide Me | http://www.whitehouse.gov/feed/media/photo-gallery | false      |
    And feed "Blog" has the following news items:
    | link                             | title       | guid  | published_ago | description                  |
    | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | First news item for the feed |
    | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | Next news item for the feed  |
    And feed "Press" has the following news items:
    | link                             | title       | guid  | published_ago | description                  |
    | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | More news items for the feed |
    | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | Last news item for the feed  |
    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    Then I should see "Everything"
    And I should see "Blog"
    And I should see "Press"
    And I should not see "Hide Me"
    And I should see "All Time"
    And I should see "Last hour"
    And I should see "Last day"
    And I should see "Last week"
    And I should see "Last month"
    And I should see "Last year"

    When I follow "Last week"
    Then I should see "First news item for the feed"
    And I should see "Next news item for the feed"
    And I should not see "More news items for the feed"
    And I should not see "Last news item for the feed"
    And I should see "Search" button

    When I follow "Last hour"
    Then I should see "no results found for 'item'"

    When I follow "Press"
    Then I should see "no results found for 'item'"

    When I follow "All Time"
    Then I should see "More news items for the feed"
    And I should see "Last news item for the feed"

    When I follow "Everything"
    Then I should see "Advanced Search"
    And I should see "Search" button
