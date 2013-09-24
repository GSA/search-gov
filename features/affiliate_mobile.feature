Feature: Mobile Search for Affiliate
  In order to get affiliate-related information on my mobile device
  As a mobile device user
  I want to be able to search with a streamlined interface

  Background:
    Given I am using a mobile device

  Scenario: A search on affiliate
    Given the following Affiliates exist:
      | display_name | name              | contact_email  | contact_name | domains | header           | footer           | is_sayt_enabled | font_family         | ga_web_property_id | external_tracking_code         |
      | agency site  | agency.gov        | aff@agency.gov | John Bar     |         | Affiliate Header | Affiliate Footer | true            | Verdana, sans-serif | UA-MOBILE-XX       | <script>var tracking;</script> |
      | no sayt site | nosayt.agency.gov | aff@agency.gov | John Bar     |         | Affiliate Header | Affiliate Footer | false           | Arial, sans-serif   |                    |                                |
    And the following Boosted Content entries exist for the affiliate "agency.gov"
      | title              | url                       | description                          |
      | Our Emergency Page | http://www.agency.gov/911 | Updated information on the emergency |
      | FAQ Emergency Page | http://www.agency.gov/faq | More information on the emergency    |
      | Our Tourism Page   | http://www.agency.gov/tou | Tourism information                  |
    And I am on agency.gov's search page
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see the page with internal CSS "font-family:Verdana,sans-serif"
    And affiliate SAYT suggestions for "agency.gov" should be enabled
    And I should see the browser page titled "agency site Mobile"
    And I should see "agency site Mobile" in the mobile page header
    And the page body should contain "_gaq.push(['_setAccount', 'UA-MOBILE-XX']);"
    And the page body should contain "<script>var tracking;</script>"
    When I fill in "query" with "emergency"
    And I submit the search form
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see the browser page titled "agency site Mobile"
    And I should see "Our Emergency Page" in the mobile boosted contents section
    And I should see the Results by Bing logo
    When I follow "Next"
    Then I should see the browser page titled "agency site Mobile"
    Then I should not see "Our Emergency Page"

    When I go to nosayt.agency.gov's mobile search page
    Then affiliate SAYT suggestions for "nosayt.agency.gov" should be disabled
    And I should see the page with internal CSS "font-family:Arial,sans-serif"

  Scenario: Toggling back to classic mode
    Given the following Affiliates exist:
      | display_name | name       | contact_email  | contact_name | domains | header           | footer           |
      | agency site  | agency.gov | aff@agency.gov | John Bar     |         | Affiliate Header | Affiliate Footer |
    And I am on agency.gov's mobile search page
    And I fill in "query" with "social security"
    And I submit the search form
    Then I should see the browser page titled "agency site Mobile"
    When I follow "Classic"
    Then I should see the browser page titled "social security - agency site Search Results"

  Scenario: A search on RSS feeds
    Given the following Affiliates exist:
      | display_name | name       | contact_email  | contact_name |
      | agency site  | agency.gov | aff@agency.gov | John Bar     |
    And affiliate "agency.gov" has the following RSS feeds:
      | name  | url                                  | is_navigable | shown_in_govbox |
      | Blog  | http://www.whitehouse.gov/feed/blog  | true         | true            |
      | Press | http://www.whitehouse.gov/feed/press | true         | true            |
    And feed "Blog" has the following news items:
      | link                             | title            | guid  | published_ago | description                        |
      | http://www.whitehouse.gov/blog/1 | First blog item  | uuid1 | day           | item 1 blog news item for the feed |
      | http://www.whitehouse.gov/blog/2 | Second blog item | uuid2 | day           | item 2 blog news item for the feed |
    And there are 40 news items for "Blog"
    And feed "Press" has the following news items:
      | link                              | title             | guid  | published_ago | description                         |
      | http://www.whitehouse.gov/press/1 | First press item  | uuid1 | day           | item 1 press news item for the feed |
      | http://www.whitehouse.gov/press/2 | Second press item | uuid2 | day           | item 2 press news item for the feed |
    When I am on agency.gov's news search page
    Then I should see "agency site Mobile"
    And I should see "First blog item"
    And I should see "Second blog item"
    And I should see "First press item"
    And I should see "Second press item"
    And I should see the Results by USASearch logo
    When I follow "Next"
    Then I should see "agency site Mobile"
    And I should see "news item 17 title for Blog"

    When I am on agency.gov's "Blog" news search page
    Then I should see "agency site Mobile"
    And I should see "First blog item"
    And I should see "Second blog item"
    And I should not see "First press item"
    And I should not see "Second press item"
    When I follow "Next"
    Then I should see "agency site Mobile"
    And I should see "news item 19 title for Blog"
    When I fill in "query" with "missing"
    And I submit the search form
    Then I should see "Sorry, no results found for 'missing'."

  Scenario: A search on document collections
    Given the following Affiliates exist:
      | display_name | name    | contact_email   | contact_name |
      | agency site  | aff.gov | contact@aff.gov | John Bar     |
    And the following site domains exist for the affiliate aff.gov:
      | domain         | site_name      |
      | aff.gov        | Agency Website |
    And affiliate "aff.gov" has the following document collections:
      | name   | prefixes                                           | is_navigable |
      | Topics | http://aff.gov/crawled/,http://www.aff.gov/topics/ | true         |
    And the following IndexedDocuments exist:
      | title                | description                                | url                                            | affiliate | last_crawled_at | last_crawl_status |
      | Space Suit Evolution | This is another document on space suit     | http://www.aff.gov/topics/space-suit.html      | aff.gov   | 11/02/2011      | OK                |
      | Space First moonwalk | This is another document on space moonwalk | http://www.aff.gov/topics/space-moonwalk.pdf   | aff.gov   | 11/02/2011      | OK                |
      | Other Space Moonwalk | This is another document on space moonwalk | http://other.aff.gov/topics/space-moonwalk.pdf | aff.gov   | 11/02/2011      | OK                |
    And there are 40 crawled IndexedDocuments for "aff.gov"
    When I am on aff.gov's "Topics" docs search page
    Then I should see "agency site Mobile"
    And I should see "Please enter search term(s)"
    When I fill in "query" with "space"
    And I submit the search form
    Then I should see "agency site Mobile"
    And I should see "Space Suit Evolution"
    And I should see "document on space suit"
    And I should see "[PDF] Space First moonwalk"
    And I should see "document on space moonwalk"
    And I should not see "Other Space Moonwalk"
    And I should see the Results by USASearch logo
    When I fill in "query" with "document"
    And I submit the search form
    And I follow "Next"
    Then I should see "agency site Mobile"
    Then I should see "crawled document"

  Scenario: Searching for site specific results using sitelimit
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | .gov    |
    When I am on agency.gov's search page with site limited to "answers.usa.gov"
    And I fill in "query" with "jobs"
    And I press "Search"
    Then I should see "answers.usa.gov/"
