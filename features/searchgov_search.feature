Feature: SearchGov search
  In order to get government-related search results
  As a site visitor to a site using the Search.gov search engine
  I want to be able to search for multiple types of data

  Background:
    Given the following SearchGov Affiliates exist:
      | display_name | name | contact_email | first_name | last_name | domains                     | youtube_handles | use_redesigned_results_page |
      | EPA          | epa  | aff@epa.gov   | Jane       | Bar       | www.epa.gov,archive.epa.gov | usgovernment    | false                       |

  Scenario: Everything search
    When I am on epa's search page
    Then I should see "Please enter a search term in the box above."
    And I should not see "Refine your search"

  Scenario: Collection search
    Given affiliate "epa" has the following document collections:
      | name | prefixes             |
      | News | www.epa.gov/one      |
    When I am on epa's "News" docs search page
    Then I should see "Please enter a search term in the box above."
    
  Scenario: Display an Alert on search page
    Given the following Alert exists:
      | affiliate | text                       | status | title      |
      | epa       | New alert for the test aff | Active | Test Title |
    When I am on epa's search page
    Then I should see "New alert for the test aff"
    Given the following Alert exists:
      | affiliate | text                       | status   | title      |
      | epa       | New alert for the test aff | Inactive | Test Title |
    When I am on epa's search page
    Then I should not see "New alert for the test aff"

  Scenario: Search with site limits
    Given there are results for the "searchgov" drawer
    When I am on epa's search page with site limited to "www.epa.gov/news"
    When I search for "carbon emissions"
    Then I should see "We're including results for carbon emissions from www.epa.gov/news only."

  Scenario: Video news search
    Given affiliate "epa" has the following RSS feeds:
      | name   | url                        | is_navigable | is_managed |
      | Videos | http://www.epa.gov/videos/ | true         | true       |
    And there are 20 video news items for "usgovernment_channel_id"

    When I am on epa's search page
    And I search for "video"
    Then I should see exactly "1" video govbox search result
    And I should see "More videos about video"
